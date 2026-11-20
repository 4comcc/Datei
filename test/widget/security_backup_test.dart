import 'dart:io';
import 'dart:typed_data';

import 'package:datei/core/security/pin_hasher.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/backup/backup_controller.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/people/presentation/people_providers.dart';
import 'package:datei/features/security/app_lock.dart';
import 'package:datei/features/settings/settings_controller.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers.dart';
import 'widget_helpers.dart';

Person _p(String id, String name) => Person(
      id: id,
      fullName: name,
      birthDate: LocalDate.parse('1990-05-02'),
      createdAt: DateTime(2026),
    );

/// Lets real async work (isolates, file I/O, Drift) finish, pumping frames, until [finder] shows.
Future<void> waitFor(WidgetTester tester, Finder finder, {int tries = 100}) async {
  for (var i = 0; i < tries; i++) {
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump(const Duration(milliseconds: 50));
    if (finder.evaluate().isNotEmpty) return;
  }
  throw TestFailure('Timed out waiting for $finder');
}

Future<void> enterPin(WidgetTester tester, String pin) async {
  for (final d in pin.split('')) {
    await tester.tap(find.byKey(Key('pin-key-$d')));
    await tester.pump();
  }
  await tester.tap(find.byKey(const Key('pin-ok')));
  await tester.pump();
}

void main() {
  testWidgets('locked app hides content until the right PIN; wrong PIN shows an error (Arabic)', (tester) async {
    final store = FakeSecureStore();
    await tester.runAsync(() async {
      store.values[AppLockController.kPinHash] = await const PinHasher(iterations: 1000).hash('2468');
    });
    await pumpApp(tester, settings: {SettingKeys.language: 'ar', SettingKeys.onboardingDone: 'true'}, secureStore: store);
    await waitFor(tester, find.byKey(const Key('lock-screen')));
    expect(find.text('التطبيق مقفل'), findsOneWidget);
    expect(find.byType(NavigationBar).hitTestable(), findsNothing);

    await enterPin(tester, '1111');
    await waitFor(tester, find.text('رمز غير صحيح'));

    await enterPin(tester, '2468');
    await waitFor(tester, find.byType(NavigationBar).hitTestable());
    expect(find.byKey(const Key('lock-screen')), findsNothing);
  });

  testWidgets('fingerprint unlock is offered automatically when turned on', (tester) async {
    final store = FakeSecureStore();
    final bio = FakeBiometrics()..available = true;
    await tester.runAsync(() async {
      store.values[AppLockController.kPinHash] = await const PinHasher(iterations: 1000).hash('2468');
      store.values[AppLockController.kBiometric] = 'true';
    });
    await pumpApp(tester, settings: englishOnboarded, secureStore: store, biometrics: bio);
    await waitFor(tester, find.byType(NavigationBar).hitTestable());
    expect(bio.prompts, 1);
  });

  testWidgets('turning the lock on from settings asks for a matching PIN', (tester) async {
    final store = FakeSecureStore();
    final c = await pumpApp(tester, settings: englishOnboarded, secureStore: store);
    router(tester, c).go('/more');
    await settle(tester);
    await tapVisible(tester, find.byKey(const Key('app-lock')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('pin-field-0')), '1234');
    await tester.enterText(find.byKey(const Key('pin-field-1')), '1235');
    await tester.tap(find.byKey(const Key('pin-dialog-ok')));
    await tester.pumpAndSettle();
    expect(find.text("PINs don't match"), findsOneWidget);

    await tester.enterText(find.byKey(const Key('pin-field-1')), '1234');
    await tester.tap(find.byKey(const Key('pin-dialog-ok')));
    await waitFor(tester, find.text('App lock is on'));
    expect(store.values[AppLockController.kPinHash], startsWith('pbkdf2-sha256'));
    expect(c.read(appLockProvider).enabled, isTrue);
    expect(find.byKey(const Key('change-pin')), findsOneWidget);
  });

  testWidgets('backup then restore brings data back, with a password', (tester) async {
    final files = FakeBackupFiles();
    final safety = Directory.systemTemp.createTempSync('datei_safety_');
    final c = await pumpApp(
      tester,
      settings: englishOnboarded,
      seed: (c) => c.read(peopleRepositoryProvider).save(_p('a', 'Amal Haddad')),
      extraOverrides: [
        backupFilesProvider.overrideWithValue(files),
        backupSafetyDirProvider.overrideWithValue(() async => safety),
      ],
    );
    router(tester, c).push('/settings/backup');
    await settle(tester);

    await tester.tap(find.byKey(const Key('backup-create')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('backup-encrypt')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('backup-password')), 'secret-1');
    await tester.enterText(find.byKey(const Key('backup-password-confirm')), 'secret-1');
    await tester.tap(find.byKey(const Key('backup-create-go')));
    await waitFor(tester, find.text('Backup saved'));
    expect(files.saved.keys.single, matches(RegExp(r'^datei-backup-\d{4}-\d{2}-\d{2}-\d{4}\.datei$')));

    // Data changes after the backup…
    await tester.runAsync(() => c.read(peopleRepositoryProvider).save(_p('b', 'Basel Nour')));
    await tester.runAsync(() => c.read(dataMaintenanceRepositoryProvider).eraseAllUserData());

    // …then the backup is restored.
    files.toPick = files.saved.values.single;
    await tester.tap(find.byKey(const Key('backup-restore')));
    await waitFor(tester, find.byKey(const Key('restore-password')));
    await tester.enterText(find.byKey(const Key('restore-password')), 'wrong-pass');
    await tester.tap(find.byKey(const Key('restore-password-go')));
    await waitFor(tester, find.text('Wrong password'));
    await tester.enterText(find.byKey(const Key('restore-password')), 'secret-1');
    await tester.tap(find.byKey(const Key('restore-password-go')));
    await waitFor(tester, find.byKey(const Key('restore-confirm')));
    expect(find.byKey(const Key('restore-count-People')), findsOneWidget);
    expect(tester.widget<Text>(find.byKey(const Key('restore-count-People'))).data, '1');

    await tester.tap(find.byKey(const Key('restore-confirm')));
    await waitFor(tester, find.text('Backup restored'));
    final people = await tester.runAsync(() => c.read(peopleRepositoryProvider).watchAll().first);
    expect(people!.map((p) => p.fullName), ['Amal Haddad']);
    expect(Directory('${safety.path}/backups').listSync().whereType<File>(), hasLength(1));
    await waitFor(tester, find.byKey(const Key('backup-undo')));
  });

  testWidgets('a file that is not a backup is rejected without changes', (tester) async {
    final files = FakeBackupFiles()..toPick = Uint8List.fromList(List.filled(64, 7));
    final c = await pumpApp(
      tester,
      settings: englishOnboarded,
      seed: (c) => c.read(peopleRepositoryProvider).save(_p('a', 'Amal Haddad')),
      extraOverrides: [
        backupFilesProvider.overrideWithValue(files),
        backupSafetyDirProvider.overrideWithValue(() async => Directory.systemTemp.createTempSync('datei_safety_')),
      ],
    );
    router(tester, c).push('/settings/backup');
    await settle(tester);
    await tester.tap(find.byKey(const Key('backup-restore')));
    await waitFor(tester, find.text("This file isn't a Datei backup, or it is damaged."));
    final people = await tester.runAsync(() => c.read(peopleRepositoryProvider).watchAll().first);
    expect(people, hasLength(1));
  });

  testWidgets('privacy policy opens from settings in both languages', (tester) async {
    final c = await pumpApp(tester, settings: {SettingKeys.language: 'ar', SettingKeys.onboardingDone: 'true'});
    router(tester, c).go('/more');
    await settle(tester);
    await tapVisible(tester, find.byKey(const Key('open-privacy')));
    await tester.pumpAndSettle();
    expect(find.text('سياسة الخصوصية'), findsOneWidget);
    expect(find.text('ما الذي يُحفظ'), findsOneWidget);
  });
}
