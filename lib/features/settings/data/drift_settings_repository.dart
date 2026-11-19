import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../domain/settings_repository.dart';

class DriftSettingsRepository implements SettingsRepository {
  DriftSettingsRepository(this._db);
  final AppDatabase _db;

  @override
  Future<Map<String, String>> loadAll() async =>
      {for (final r in await _db.select(_db.appSettings).get()) r.key: r.value};

  @override
  Future<void> set(String key, String value) => _db
      .into(_db.appSettings)
      .insertOnConflictUpdate(AppSettingsCompanion.insert(key: key, value: value, updatedAt: nowUtcMs()));
}

class DriftDataMaintenanceRepository implements DataMaintenanceRepository {
  DriftDataMaintenanceRepository(this._db);
  final AppDatabase _db;

  @override
  Future<void> eraseAllUserData() => _db.transaction(() async {
        await _db.delete(_db.eventPersonRelations).go();
        await _db.delete(_db.personRelationships).go();
        await _db.delete(_db.customFieldValues).go();
        await _db.delete(_db.personCategoryRelations).go();
        await _db.delete(_db.events).go();
        await _db.delete(_db.recurrenceRules).go();
        await _db.delete(_db.persons).go();
        // User-created categories/types go too; system rows stay. Custom field
        // definitions and saved filters are configuration and are kept.
        await (_db.delete(_db.personCategories)..where((t) => t.isSystem.equals(false))).go();
        await (_db.delete(_db.eventTypes)..where((t) => t.isSystem.equals(false))).go();
      });
}
