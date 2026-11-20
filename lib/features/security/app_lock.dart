import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/database_providers.dart';
import '../../core/security/pin_hasher.dart';
import '../../core/security/secure_store.dart';

final secureStoreProvider = Provider<SecureStore>((ref) => const DeviceSecureStore());
final biometricsProvider = Provider<Biometrics>((ref) => DeviceBiometrics());
final pinHasherProvider = Provider<PinHasher>((ref) => const PinHasher());

/// Current time in UTC epoch millis (overridden in tests).
final lockClockProvider = Provider<int Function()>((ref) => nowUtcMs);

enum PinAttempt { ok, wrong, lockedOut }

class AppLockState {
  const AppLockState({
    this.loaded = false,
    this.enabled = false,
    this.biometricEnabled = false,
    this.biometricAvailable = false,
    this.lockAfterSeconds = AppLockController.defaultLockAfter,
    this.locked = false,
    this.failures = 0,
    this.lockedUntilMs = 0,
  });

  final bool loaded;
  final bool enabled;
  final bool biometricEnabled;
  final bool biometricAvailable;

  /// Time in the background before the app locks again (0 = immediately).
  final int lockAfterSeconds;
  final bool locked;

  /// Consecutive wrong PINs.
  final int failures;

  /// While in the future, PIN entry is refused.
  final int lockedUntilMs;

  /// Hides content: still loading, or locked.
  bool get blocking => !loaded || locked;

  AppLockState copyWith({
    bool? loaded,
    bool? enabled,
    bool? biometricEnabled,
    bool? biometricAvailable,
    int? lockAfterSeconds,
    bool? locked,
    int? failures,
    int? lockedUntilMs,
  }) =>
      AppLockState(
        loaded: loaded ?? this.loaded,
        enabled: enabled ?? this.enabled,
        biometricEnabled: biometricEnabled ?? this.biometricEnabled,
        biometricAvailable: biometricAvailable ?? this.biometricAvailable,
        lockAfterSeconds: lockAfterSeconds ?? this.lockAfterSeconds,
        locked: locked ?? this.locked,
        failures: failures ?? this.failures,
        lockedUntilMs: lockedUntilMs ?? this.lockedUntilMs,
      );
}

/// App lock (ADR-065). Everything lives in the device's secure storage, never in
/// the database, so it is not part of backups and does not travel to another phone.
class AppLockController extends Notifier<AppLockState> {
  static const kPinHash = 'lock.pin_hash';
  static const kBiometric = 'lock.biometric';
  static const kLockAfter = 'lock.after_seconds';
  static const kFailures = 'lock.failures';
  static const kLockedUntil = 'lock.locked_until';

  static const defaultLockAfter = 60;
  static const lockAfterChoices = [0, 60, 300];

  /// Wrong PINs allowed before a timed lockout.
  static const freeAttempts = 5;
  static const baseLockoutSeconds = 30;
  static const maxLockoutSeconds = 15 * 60;

  /// Lockout length after [failures] consecutive wrong PINs (0 = none).
  static int lockoutSecondsFor(int failures) {
    if (failures < freeAttempts) return 0;
    final doublings = math.min(failures - freeAttempts, 10);
    return math.min(baseLockoutSeconds * (1 << doublings), maxLockoutSeconds);
  }

  SecureStore get _store => ref.read(secureStoreProvider);
  int _now() => ref.read(lockClockProvider)();

  final _ready = Completer<void>();
  Future<void> get ready => _ready.future;

  int? _backgroundSince;
  int _external = 0;

  @override
  AppLockState build() {
    Future.microtask(_load);
    return const AppLockState();
  }

  /// A storage failure or hang must never leave the user on a blank screen
  /// (ADR-065): the read is abandoned after a few seconds and treated as empty.
  Future<String?> _read(String key) async {
    try {
      return await _store.read(key).timeout(const Duration(seconds: 4));
    } catch (e) {
      debugPrint('Secure storage read failed ($key): $e');
      return null;
    }
  }

  Future<void> _load() async {
    try {
      final hash = await _read(kPinHash);
      final enabled = hash != null && hash.isNotEmpty;
      final bioAvailable = await ref.read(biometricsProvider).isAvailable().timeout(
            const Duration(seconds: 4),
            onTimeout: () => false,
          );
      final after = int.tryParse(await _read(kLockAfter) ?? '');
      state = AppLockState(
        loaded: true,
        enabled: enabled,
        biometricEnabled: enabled && bioAvailable && await _read(kBiometric) == 'true',
        biometricAvailable: bioAvailable,
        lockAfterSeconds: lockAfterChoices.contains(after) ? after! : defaultLockAfter,
        locked: enabled,
        failures: int.tryParse(await _read(kFailures) ?? '') ?? 0,
        lockedUntilMs: int.tryParse(await _read(kLockedUntil) ?? '') ?? 0,
      );
    } finally {
      if (!state.loaded) state = state.copyWith(loaded: true);
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  /// Remaining lockout in whole seconds (0 when PIN entry is allowed).
  int lockoutRemainingSeconds() {
    final ms = state.lockedUntilMs - _now();
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  /// Checks [pin] against the stored hash, counting failures and applying lockouts.
  Future<PinAttempt> checkPin(String pin) async {
    if (lockoutRemainingSeconds() > 0) return PinAttempt.lockedOut;
    final stored = await _read(kPinHash);
    if (stored != null && await ref.read(pinHasherProvider).verify(pin, stored)) {
      await _resetFailures();
      return PinAttempt.ok;
    }
    final failures = state.failures + 1;
    final lockout = lockoutSecondsFor(failures);
    final until = lockout == 0 ? 0 : _now() + lockout * 1000;
    state = state.copyWith(failures: failures, lockedUntilMs: until);
    await _store.write(kFailures, '$failures');
    await _store.write(kLockedUntil, '$until');
    return lockout == 0 ? PinAttempt.wrong : PinAttempt.lockedOut;
  }

  Future<void> _resetFailures() async {
    if (state.failures == 0 && state.lockedUntilMs == 0) return;
    state = state.copyWith(failures: 0, lockedUntilMs: 0);
    await _store.delete(kFailures);
    await _store.delete(kLockedUntil);
  }

  Future<PinAttempt> unlockWithPin(String pin) async {
    final result = await checkPin(pin);
    if (result == PinAttempt.ok) state = state.copyWith(locked: false);
    return result;
  }

  Future<bool> unlockWithBiometrics(String reason) async {
    if (!state.biometricEnabled) return false;
    final ok = await whileExternal(() => ref.read(biometricsProvider).authenticate(reason));
    if (ok) {
      await _resetFailures();
      state = state.copyWith(locked: false);
    }
    return ok;
  }

  /// Turns the lock on with a new PIN.
  Future<void> enable(String pin) async {
    if (!PinHasher.isValidPin(pin)) throw ArgumentError('PIN must be 4–8 digits');
    await _store.write(kPinHash, await ref.read(pinHasherProvider).hash(pin));
    await _store.write(kLockAfter, '${state.lockAfterSeconds}');
    await _resetFailures();
    state = state.copyWith(enabled: true, locked: false, biometricEnabled: false);
  }

  Future<PinAttempt> changePin(String currentPin, String newPin) async {
    if (!PinHasher.isValidPin(newPin)) throw ArgumentError('PIN must be 4–8 digits');
    final result = await checkPin(currentPin);
    if (result == PinAttempt.ok) {
      await _store.write(kPinHash, await ref.read(pinHasherProvider).hash(newPin));
    }
    return result;
  }

  /// Turns the lock off; requires the current PIN.
  Future<PinAttempt> disable(String pin) async {
    final result = await checkPin(pin);
    if (result == PinAttempt.ok) {
      for (final k in [kPinHash, kBiometric, kFailures, kLockedUntil]) {
        await _store.delete(k);
      }
      state = state.copyWith(enabled: false, biometricEnabled: false, locked: false, failures: 0, lockedUntilMs: 0);
    }
    return result;
  }

  /// Enabling asks for a successful scan first, so a broken sensor can't be turned on.
  Future<bool> setBiometric(bool on, {required String reason}) async {
    if (!state.enabled) return false;
    if (on) {
      if (!state.biometricAvailable) return false;
      final ok = await whileExternal(() => ref.read(biometricsProvider).authenticate(reason));
      if (!ok) return false;
    }
    await _store.write(kBiometric, '$on');
    state = state.copyWith(biometricEnabled: on);
    return true;
  }

  Future<void> setLockAfter(int seconds) async {
    if (!lockAfterChoices.contains(seconds)) throw ArgumentError.value(seconds, 'seconds');
    await _store.write(kLockAfter, '$seconds');
    state = state.copyWith(lockAfterSeconds: seconds);
  }

  /// Locks now (e.g. from a menu).
  void lockNow() {
    if (state.enabled) state = state.copyWith(locked: true);
  }

  void onBackground() {
    if (state.enabled && !state.locked && _external == 0) _backgroundSince = _now();
  }

  void onForeground() {
    final since = _backgroundSince;
    _backgroundSince = null;
    if (since == null || !state.enabled) return;
    if (_now() - since >= state.lockAfterSeconds * 1000) state = state.copyWith(locked: true);
  }

  /// Runs [action] (system file picker, biometric prompt…) without locking when
  /// the app briefly goes to the background because of it.
  Future<T> whileExternal<T>(Future<T> Function() action) async {
    _external++;
    try {
      return await action();
    } finally {
      _external--;
      _backgroundSince = null;
    }
  }
}

final appLockProvider = NotifierProvider<AppLockController, AppLockState>(AppLockController.new);
