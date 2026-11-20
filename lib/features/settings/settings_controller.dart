import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/database/database_providers.dart';
import '../../core/time_engine/hijri.dart';
import 'data/drift_settings_repository.dart';
import 'domain/settings_repository.dart';

class AppSettings {
  const AppSettings({
    required this.languageCode,
    required this.onboardingDone,
    required this.themeMode,
    this.showHijri = false,
    this.hijriOffset = 0,
    this.remindersEnabled = false,
    this.reminderTime = '09:00',
    this.birthdayReminderDays,
    this.preciseReminders = false,
  });

  factory AppSettings.fromMap(Map<String, String> m) => AppSettings(
        languageCode: m[SettingKeys.language],
        onboardingDone: m[SettingKeys.onboardingDone] == 'true',
        themeMode: ThemeMode.values.asNameMap()[m[SettingKeys.themeMode]] ?? ThemeMode.system,
        showHijri: m[SettingKeys.showHijri] == 'true',
        hijriOffset: (int.tryParse(m[SettingKeys.hijriOffset] ?? '') ?? 0).clamp(-2, 2),
        remindersEnabled: m[SettingKeys.remindersEnabled] == 'true',
        reminderTime: RegExp(r'^\d{2}:\d{2}$').hasMatch(m[SettingKeys.reminderTime] ?? '') ? m[SettingKeys.reminderTime]! : '09:00',
        birthdayReminderDays: switch (int.tryParse(m[SettingKeys.birthdayReminderDays] ?? '')) {
          final d? when d >= 0 => d,
          _ => m.containsKey(SettingKeys.birthdayReminderDays) ? null : 1,
        },
        preciseReminders: m[SettingKeys.preciseReminders] == 'true',
      );

  /// null until the user picks a language on first launch.
  final String? languageCode;
  final bool onboardingDone;
  final ThemeMode themeMode;
  final bool showHijri;

  /// −2…+2 days added to Umm al-Qura dates (local moon sighting).
  final int hijriOffset;
  final bool remindersEnabled;

  /// `HH:mm` for reminders of all-day items.
  final String reminderTime;

  /// Days before birthdays (null = off). Defaults to 1 until the user changes it.
  final int? birthdayReminderDays;
  final bool preciseReminders;

  Locale? get locale => languageCode == null ? null : Locale(languageCode!);

  AppSettings copyWith({
    String? languageCode,
    bool? onboardingDone,
    ThemeMode? themeMode,
    bool? showHijri,
    int? hijriOffset,
    bool? remindersEnabled,
    String? reminderTime,
    int? Function()? birthdayReminderDays,
    bool? preciseReminders,
  }) =>
      AppSettings(
        languageCode: languageCode ?? this.languageCode,
        onboardingDone: onboardingDone ?? this.onboardingDone,
        themeMode: themeMode ?? this.themeMode,
        showHijri: showHijri ?? this.showHijri,
        hijriOffset: hijriOffset ?? this.hijriOffset,
        remindersEnabled: remindersEnabled ?? this.remindersEnabled,
        reminderTime: reminderTime ?? this.reminderTime,
        birthdayReminderDays: birthdayReminderDays != null ? birthdayReminderDays() : this.birthdayReminderDays,
        preciseReminders: preciseReminders ?? this.preciseReminders,
      );
}

abstract final class SettingKeys {
  static const language = 'general.language';
  static const onboardingDone = 'general.onboarding_done';
  static const themeMode = 'general.theme_mode';
  static const showHijri = 'calendar.show_hijri';
  static const hijriOffset = 'calendar.hijri_offset';
  static const remindersEnabled = 'notifications.enabled';
  static const reminderTime = 'notifications.default_time';
  static const birthdayReminderDays = 'notifications.birthday_days';
  static const preciseReminders = 'notifications.precise';
  static const lastCurrency = 'commitments.last_currency';
}

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => DriftSettingsRepository(ref.watch(appDatabaseProvider)));

final dataMaintenanceRepositoryProvider =
    Provider<DataMaintenanceRepository>(
  (ref) => DriftDataMaintenanceRepository(ref.watch(appDatabaseProvider), ref.watch(attachmentStoreProvider)),
);

/// Settings loaded before `runApp` so the router can decide the first screen synchronously.
final initialSettingsProvider = Provider<Map<String, String>>(
  (ref) => throw UnimplementedError('initialSettingsProvider must be overridden'),
);

class SettingsController extends Notifier<AppSettings> {
  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  @override
  AppSettings build() => AppSettings.fromMap(ref.watch(initialSettingsProvider));

  Future<void> setLanguage(String code) async {
    await _repo.set(SettingKeys.language, code);
    state = state.copyWith(languageCode: code);
  }

  Future<void> completeOnboarding() async {
    await _repo.set(SettingKeys.onboardingDone, 'true');
    state = state.copyWith(onboardingDone: true);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _repo.set(SettingKeys.themeMode, mode.name);
    state = state.copyWith(themeMode: mode);
  }

  Future<void> setShowHijri(bool value) async {
    await _repo.set(SettingKeys.showHijri, '$value');
    state = state.copyWith(showHijri: value);
  }

  Future<void> setHijriOffset(int days) async {
    final v = days.clamp(-2, 2);
    await _repo.set(SettingKeys.hijriOffset, '$v');
    state = state.copyWith(hijriOffset: v);
  }

  Future<void> setRemindersEnabled(bool v) async {
    await _repo.set(SettingKeys.remindersEnabled, '$v');
    state = state.copyWith(remindersEnabled: v);
  }

  Future<void> setReminderTime(String hhmm) async {
    await _repo.set(SettingKeys.reminderTime, hhmm);
    state = state.copyWith(reminderTime: hhmm);
  }

  /// null turns birthday reminders off.
  Future<void> setBirthdayReminderDays(int? days) async {
    await _repo.set(SettingKeys.birthdayReminderDays, '${days ?? -1}');
    state = state.copyWith(birthdayReminderDays: () => days);
  }

  Future<void> setPreciseReminders(bool v) async {
    await _repo.set(SettingKeys.preciseReminders, '$v');
    state = state.copyWith(preciseReminders: v);
  }}

final hijriConverterProvider = Provider<HijriConverter>(
  (ref) => HijriConverter(offsetDays: ref.watch(settingsProvider.select((s) => s.hijriOffset))),
);

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
