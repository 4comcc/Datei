import 'package:datei/app/bootstrap.dart';
import 'package:datei/core/database/app_database.dart';
import 'package:datei/core/database/database_providers.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/agenda/agenda.dart';
import 'package:datei/features/reminders/reminder_sync.dart';
import 'package:datei/features/settings/settings_controller.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

export 'fakes.dart';

const testToday = LocalDate(2026, 11, 19);

AppDatabase openTestDatabase() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  return AppDatabase(NativeDatabase.memory());
}

/// Fresh in-memory database + bootstrap, wired into a ProviderContainer.
Future<(ProviderContainer, AppDatabase)> createTestContainer({
  Map<String, Object> legacyPrefs = const {},
  Map<String, String> settings = const {},
  FakeNotificationGateway? notifications,
}) async {
  SharedPreferences.setMockInitialValues(legacyPrefs);
  final prefs = await SharedPreferences.getInstance();
  final db = openTestDatabase();
  final repoSettings = await bootstrap(db, prefs);
  final merged = {...repoSettings.settings, ...settings};
  final container = ProviderContainer(overrides: [
    appDatabaseProvider.overrideWithValue(db),
    currentProfileIdProvider.overrideWithValue(repoSettings.profileId),
    initialSettingsProvider.overrideWithValue(merged),
    todayProvider.overrideWithValue(testToday),
    notificationGatewayProvider.overrideWithValue(notifications ?? FakeNotificationGateway()),
  ]);
  return (container, db);
}

const englishOnboarded = {SettingKeys.language: 'en', SettingKeys.onboardingDone: 'true'};
