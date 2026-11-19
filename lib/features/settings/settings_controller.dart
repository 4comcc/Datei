import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/database/database_providers.dart';
import 'data/drift_settings_repository.dart';
import 'domain/settings_repository.dart';

class AppSettings {
  const AppSettings({
    required this.languageCode,
    required this.onboardingDone,
    required this.themeMode,
  });

  factory AppSettings.fromMap(Map<String, String> m) => AppSettings(
        languageCode: m[SettingKeys.language],
        onboardingDone: m[SettingKeys.onboardingDone] == 'true',
        themeMode: ThemeMode.values.asNameMap()[m[SettingKeys.themeMode]] ?? ThemeMode.system,
      );

  /// null until the user picks a language on first launch.
  final String? languageCode;
  final bool onboardingDone;
  final ThemeMode themeMode;

  Locale? get locale => languageCode == null ? null : Locale(languageCode!);

  AppSettings copyWith({String? languageCode, bool? onboardingDone, ThemeMode? themeMode}) => AppSettings(
        languageCode: languageCode ?? this.languageCode,
        onboardingDone: onboardingDone ?? this.onboardingDone,
        themeMode: themeMode ?? this.themeMode,
      );
}

abstract final class SettingKeys {
  static const language = 'general.language';
  static const onboardingDone = 'general.onboarding_done';
  static const themeMode = 'general.theme_mode';
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
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
