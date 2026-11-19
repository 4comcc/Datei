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
  });

  factory AppSettings.fromMap(Map<String, String> m) => AppSettings(
        languageCode: m[SettingKeys.language],
        onboardingDone: m[SettingKeys.onboardingDone] == 'true',
        themeMode: ThemeMode.values.asNameMap()[m[SettingKeys.themeMode]] ?? ThemeMode.system,
        showHijri: m[SettingKeys.showHijri] == 'true',
        hijriOffset: (int.tryParse(m[SettingKeys.hijriOffset] ?? '') ?? 0).clamp(-2, 2),
      );

  /// null until the user picks a language on first launch.
  final String? languageCode;
  final bool onboardingDone;
  final ThemeMode themeMode;
  final bool showHijri;

  /// −2…+2 days added to Umm al-Qura dates (local moon sighting).
  final int hijriOffset;

  Locale? get locale => languageCode == null ? null : Locale(languageCode!);

  AppSettings copyWith({
    String? languageCode,
    bool? onboardingDone,
    ThemeMode? themeMode,
    bool? showHijri,
    int? hijriOffset,
  }) =>
      AppSettings(
        languageCode: languageCode ?? this.languageCode,
        onboardingDone: onboardingDone ?? this.onboardingDone,
        themeMode: themeMode ?? this.themeMode,
        showHijri: showHijri ?? this.showHijri,
        hijriOffset: hijriOffset ?? this.hijriOffset,
      );
}

abstract final class SettingKeys {
  static const language = 'general.language';
  static const onboardingDone = 'general.onboarding_done';
  static const themeMode = 'general.theme_mode';
  static const showHijri = 'calendar.show_hijri';
  static const hijriOffset = 'calendar.hijri_offset';
}

final settingsRepositoryProvider =
    Provider<SettingsRepository>((ref) => DriftSettingsRepository(ref.watch(appDatabaseProvider)));

final dataMaintenanceRepositoryProvider =
    Provider<DataMaintenanceRepository>((ref) => DriftDataMaintenanceRepository(ref.watch(appDatabaseProvider)));

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
}

final hijriConverterProvider = Provider<HijriConverter>(
  (ref) => HijriConverter(offsetDays: ref.watch(settingsProvider.select((s) => s.hijriOffset))),
);

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
