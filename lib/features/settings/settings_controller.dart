import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/storage/local_store.dart';

class AppSettings {
  const AppSettings({
    required this.languageCode,
    required this.onboardingDone,
    required this.themeMode,
  });

  /// null until the user picks a language on first launch.
  final String? languageCode;
  final bool onboardingDone;
  final ThemeMode themeMode;

  Locale? get locale => languageCode == null ? null : Locale(languageCode!);

  AppSettings copyWith({String? languageCode, bool? onboardingDone, ThemeMode? themeMode}) =>
      AppSettings(
        languageCode: languageCode ?? this.languageCode,
        onboardingDone: onboardingDone ?? this.onboardingDone,
        themeMode: themeMode ?? this.themeMode,
      );
}

class SettingsController extends Notifier<AppSettings> {
  static const _kLanguage = 'settings.language';
  static const _kOnboarding = 'settings.onboardingDone';
  static const _kTheme = 'settings.themeMode';

  @override
  AppSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    return AppSettings(
      languageCode: prefs.getString(_kLanguage),
      onboardingDone: prefs.getBool(_kOnboarding) ?? false,
      themeMode: ThemeMode.values.asNameMap()[prefs.getString(_kTheme)] ?? ThemeMode.system,
    );
  }

  Future<void> setLanguage(String code) async {
    await ref.read(sharedPreferencesProvider).setString(_kLanguage, code);
    state = state.copyWith(languageCode: code);
  }

  Future<void> completeOnboarding() async {
    await ref.read(sharedPreferencesProvider).setBool(_kOnboarding, true);
    state = state.copyWith(onboardingDone: true);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await ref.read(sharedPreferencesProvider).setString(_kTheme, mode.name);
    state = state.copyWith(themeMode: mode);
  }
}

final settingsProvider =
    NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
