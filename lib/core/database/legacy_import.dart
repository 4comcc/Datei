import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../features/events/data/drift_events_repository.dart';
import '../../features/events/domain/event.dart';
import '../../features/people/data/drift_people_repository.dart';
import '../../features/people/domain/person.dart';
import '../../features/settings/data/drift_settings_repository.dart';
import '../../features/settings/settings_controller.dart';
import 'app_database.dart';

/// One-time import of data saved by prototype v0.1 (JSON in SharedPreferences)
/// into the Drift database. Runs inside one transaction; the old keys are removed
/// only after the transaction commits, so a failure leaves the old data intact.
class LegacyPrototypeImporter {
  LegacyPrototypeImporter(this._db, this._prefs, this._profileId);
  final AppDatabase _db;
  final SharedPreferences _prefs;
  final String _profileId;

  static const _people = 'data.people';
  static const _events = 'data.events';
  static const _settingsMap = {
    'settings.language': SettingKeys.language,
    'settings.onboardingDone': SettingKeys.onboardingDone,
    'settings.themeMode': SettingKeys.themeMode,
  };

  bool get hasLegacyData =>
      _prefs.containsKey(_people) || _prefs.containsKey(_events) || _settingsMap.keys.any(_prefs.containsKey);

  /// Returns the number of imported records (people + events).
  Future<int> run() async {
    if (!hasLegacyData) return 0;
    final people = _decode(_people).map(Person.fromJson).toList();
    final events = _decode(_events).map(DateiEvent.fromJson).toList();
    final peopleRepo = DriftPeopleRepository(_db, _profileId);
    final eventsRepo = DriftEventsRepository(_db, _profileId);
    final settingsRepo = DriftSettingsRepository(_db);

    await _db.transaction(() async {
      for (final entry in _settingsMap.entries) {
        final v = _prefs.get(entry.key);
        if (v != null) await settingsRepo.set(entry.value, v.toString());
      }
      for (final p in people) {
        await peopleRepo.save(p);
      }
      for (final e in events) {
        await eventsRepo.save(e);
      }
    });

    for (final k in [_people, _events, ..._settingsMap.keys]) {
      await _prefs.remove(k);
    }
    return people.length + events.length;
  }

  List<Map<String, dynamic>> _decode(String key) {
    final raw = _prefs.getString(key);
    if (raw == null || raw.isEmpty) return const [];
    try {
      return (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
    } on FormatException {
      return const [];
    }
  }
}
