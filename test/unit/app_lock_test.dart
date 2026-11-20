import 'package:datei/core/security/pin_hasher.dart';
import 'package:datei/features/security/app_lock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../fakes.dart';

void main() {
  group('PinHasher', () {
    const hasher = PinHasher(iterations: 1000);

    test('verifies the right PIN only and never stores it', () async {
      final stored = await hasher.hash('2468');
      expect(stored, startsWith(r'pbkdf2-sha256$1000$'));
      expect(stored, isNot(contains('2468')));
      expect(await hasher.verify('2468', stored), isTrue);
      expect(await hasher.verify('2469', stored), isFalse);
      expect(await hasher.verify('24680', stored), isFalse);
    });

    test('uses a fresh salt every time', () async {
      expect(await hasher.hash('1111'), isNot(await hasher.hash('1111')));
    });

    test('rejects malformed stored values', () async {
      for (final bad in ['', 'plain', r'md5$1$a$b', r'pbkdf2-sha256$x$a$b', r'pbkdf2-sha256$10$***$***']) {
        expect(await hasher.verify('1234', bad), isFalse, reason: bad);
      }
    });

    test('accepts 4 to 8 digits', () {
      expect(PinHasher.isValidPin('1234'), isTrue);
      expect(PinHasher.isValidPin('12345678'), isTrue);
      expect(PinHasher.isValidPin('123'), isFalse);
      expect(PinHasher.isValidPin('123456789'), isFalse);
      expect(PinHasher.isValidPin('12a4'), isFalse);
      expect(PinHasher.isValidPin('١٢٣٤'), isFalse);
    });
  });

  group('AppLockController', () {
    late FakeSecureStore store;
    late FakeBiometrics bio;
    late int now;

    Future<(ProviderContainer, AppLockController)> start() async {
      final c = ProviderContainer(overrides: [
        secureStoreProvider.overrideWithValue(store),
        biometricsProvider.overrideWithValue(bio),
        pinHasherProvider.overrideWithValue(const PinHasher(iterations: 1000)),
        lockClockProvider.overrideWithValue(() => now),
      ]);
      addTearDown(c.dispose);
      c.listen(appLockProvider, (_, _) {});
      final n = c.read(appLockProvider.notifier);
      await n.ready;
      return (c, n);
    }

    setUp(() {
      store = FakeSecureStore();
      bio = FakeBiometrics();
      now = 1_000_000;
    });

    test('is off by default and never blocks', () async {
      final (c, _) = await start();
      final s = c.read(appLockProvider);
      expect(s.loaded, isTrue);
      expect(s.enabled, isFalse);
      expect(s.blocking, isFalse);
    });

    test('enabling stores only a hash and locks on the next cold start', () async {
      final (c, n) = await start();
      await n.enable('1234');
      expect(c.read(appLockProvider).locked, isFalse);
      expect(store.values[AppLockController.kPinHash], isNot(contains('1234')));

      final (c2, n2) = await start();
      expect(c2.read(appLockProvider).locked, isTrue);
      expect(await n2.unlockWithPin('0000'), PinAttempt.wrong);
      expect(c2.read(appLockProvider).locked, isTrue);
      expect(await n2.unlockWithPin('1234'), PinAttempt.ok);
      expect(c2.read(appLockProvider).locked, isFalse);
    });

    test('lockout grows from 30 s and is capped at 15 min', () {
      expect(AppLockController.lockoutSecondsFor(4), 0);
      expect(AppLockController.lockoutSecondsFor(5), 30);
      expect(AppLockController.lockoutSecondsFor(6), 60);
      expect(AppLockController.lockoutSecondsFor(9), 480);
      expect(AppLockController.lockoutSecondsFor(10), 900);
      expect(AppLockController.lockoutSecondsFor(500), 900);
    });

    test('five wrong PINs lock PIN entry, even after a restart, until the time passes', () async {
      final (_, n) = await start();
      await n.enable('1234');
      for (var i = 0; i < 4; i++) {
        expect(await n.checkPin('9999'), PinAttempt.wrong);
      }
      expect(await n.checkPin('9999'), PinAttempt.lockedOut);
      expect(n.lockoutRemainingSeconds(), 30);
      expect(await n.unlockWithPin('1234'), PinAttempt.lockedOut, reason: 'right PIN refused during lockout');

      final (c2, n2) = await start();
      expect(c2.read(appLockProvider).failures, 5);
      expect(await n2.unlockWithPin('1234'), PinAttempt.lockedOut);

      now += 31 * 1000;
      expect(await n2.checkPin('9999'), PinAttempt.lockedOut, reason: '6th failure doubles the wait');
      expect(n2.lockoutRemainingSeconds(), 60);
      now += 61 * 1000;
      expect(await n2.unlockWithPin('1234'), PinAttempt.ok);
      expect(c2.read(appLockProvider).failures, 0);
      expect(store.values.containsKey(AppLockController.kFailures), isFalse);
    });

    test('locks again only after the chosen time in the background', () async {
      final (c, n) = await start();
      await n.enable('1234');
      expect(c.read(appLockProvider).lockAfterSeconds, 60);

      n.onBackground();
      now += 30 * 1000;
      n.onForeground();
      expect(c.read(appLockProvider).locked, isFalse);

      n.onBackground();
      now += 60 * 1000;
      n.onForeground();
      expect(c.read(appLockProvider).locked, isTrue);

      await n.unlockWithPin('1234');
      await n.setLockAfter(0);
      n.onBackground();
      n.onForeground();
      expect(c.read(appLockProvider).locked, isTrue);
      expect(() => n.setLockAfter(42), throwsArgumentError);
    });

    test('system pickers and prompts do not relock the app', () async {
      final (c, n) = await start();
      await n.enable('1234');
      await n.setLockAfter(0);
      await n.whileExternal(() async {
        n.onBackground();
        now += 600 * 1000;
        n.onForeground();
      });
      expect(c.read(appLockProvider).locked, isFalse);
    });

    test('biometrics: only when available, confirmed by a scan, and usable to unlock', () async {
      final (c, n) = await start();
      await n.enable('1234');
      expect(await n.setBiometric(true, reason: 'r'), isFalse, reason: 'no sensor');

      bio.available = true;
      final (c2, n2) = await start();
      expect(c2.read(appLockProvider).biometricAvailable, isTrue);
      bio.succeed = false;
      expect(await n2.setBiometric(true, reason: 'r'), isFalse);
      bio.succeed = true;
      expect(await n2.setBiometric(true, reason: 'r'), isTrue);

      final (c3, n3) = await start();
      expect(c3.read(appLockProvider).biometricEnabled, isTrue);
      bio.succeed = false;
      expect(await n3.unlockWithBiometrics('r'), isFalse);
      expect(c3.read(appLockProvider).locked, isTrue);
      bio.succeed = true;
      expect(await n3.unlockWithBiometrics('r'), isTrue);
      expect(c3.read(appLockProvider).locked, isFalse);
      expect(c.read(appLockProvider).enabled, isTrue);
    });

    test('changing and disabling require the current PIN', () async {
      final (c, n) = await start();
      await n.enable('1234');
      expect(await n.changePin('0000', '5678'), PinAttempt.wrong);
      expect(await n.changePin('1234', '5678'), PinAttempt.ok);
      expect(await n.disable('1234'), PinAttempt.wrong);
      expect(c.read(appLockProvider).enabled, isTrue);
      expect(await n.disable('5678'), PinAttempt.ok);
      expect(c.read(appLockProvider).enabled, isFalse);
      expect(store.values, isEmpty.or(containsPair(AppLockController.kLockAfter, '60')));
      expect(() => n.enable('12'), throwsArgumentError);
    });
  });
}

extension on Matcher {
  Matcher or(Matcher other) => anyOf(this, other);
}
