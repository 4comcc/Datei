import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/services/attachment_store.dart';
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
  DriftDataMaintenanceRepository(this._db, [this._files]);
  final AppDatabase _db;
  final AttachmentStore? _files;

  @override
  Future<void> eraseAllUserData() async {
    await _eraseRows();
    await _files?.deleteAll();
  }

  Future<void> _eraseRows() => _db.transaction(() async {
        await _db.delete(_db.eventPersonRelations).go();
        await _db.delete(_db.personRelationships).go();
        await _db.delete(_db.customFieldValues).go();
        await _db.delete(_db.personCategoryRelations).go();
        await _db.delete(_db.attachments).go();
        await _db.delete(_db.entityTagRelations).go();
        await _db.delete(_db.tags).go();
        await _db.delete(_db.memoryPersonRelations).go();
        await _db.delete(_db.memories).go();
        await _db.delete(_db.milestones).go();
        await _db.delete(_db.projectPersonRelations).go();
        await _db.delete(_db.projectEventRelations).go();
        await _db.delete(_db.projects).go();
        await _db.delete(_db.reminders).go();
        await _db.delete(_db.commitmentRenewals).go();
        await _db.delete(_db.commitments).go();
        await (_db.delete(_db.commitmentTypes)..where((t) => t.isSystem.equals(false))).go();
        await _db.delete(_db.events).go();
        await _db.delete(_db.recurrenceRules).go();
        await _db.delete(_db.persons).go();
        // User-created categories/types go too; system rows stay. Custom field
        // definitions and saved filters are configuration and are kept.
        await (_db.delete(_db.personCategories)..where((t) => t.isSystem.equals(false))).go();
        await (_db.delete(_db.eventTypes)..where((t) => t.isSystem.equals(false))).go();
      });
}
