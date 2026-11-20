import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../core/database/app_database.dart';
import '../core/database/database_providers.dart';
import '../core/database/legacy_import.dart';
import '../features/settings/data/drift_settings_repository.dart';

class BootstrapResult {
  const BootstrapResult({required this.profileId, required this.settings, this.attachmentsRoot});
  final String profileId;
  final Map<String, String> settings;

  /// Absolute directory for attachments (app documents directory).
  final String? attachmentsRoot;
}

/// Prepares local state before the first frame: ensures the device's local
/// profile exists, imports prototype data once, and loads settings.
Future<BootstrapResult> bootstrap(AppDatabase db, SharedPreferences prefs, {String? attachmentsRoot}) async {
  final profileId = await ensureLocalProfile(db);
  await LegacyPrototypeImporter(db, prefs, profileId).run();
  final settings = await DriftSettingsRepository(db).loadAll();
  return BootstrapResult(profileId: profileId, settings: settings, attachmentsRoot: attachmentsRoot);
}

Future<String> ensureLocalProfile(AppDatabase db) async {
  final existing = await (db.select(db.localUserProfiles)..limit(1)).getSingleOrNull();
  if (existing != null) return existing.id;
  final now = nowUtcMs();
  final id = const Uuid().v4();
  await db.into(db.localUserProfiles).insert(LocalUserProfilesCompanion.insert(id: id, createdAt: now, updatedAt: now));
  return id;
}
