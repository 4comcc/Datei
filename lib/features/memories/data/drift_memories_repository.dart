import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/services/attachment_store.dart';
import '../../../core/time_engine/local_date.dart';
import '../domain/memory.dart';

class DriftMemoriesRepository implements MemoriesRepository {
  DriftMemoriesRepository(this._db, this._profileId, this._files);
  final AppDatabase _db;
  final String _profileId;
  final AttachmentStore _files;

  static const _sql = '''
SELECT m.*,
  (SELECT group_concat(r.person_id) FROM memory_person_relations r
     JOIN persons p ON p.id = r.person_id AND p.deleted_at IS NULL WHERE r.memory_id = m.id) AS person_ids,
  (SELECT json_group_array(t.name) FROM entity_tag_relations x JOIN tags t ON t.id = x.tag_id
    WHERE x.entity_type = 'memory' AND x.entity_id = m.id) AS tag_names,
  (SELECT json_group_array(json_object('id', a.id, 'p', a.relative_path, 'm', a.mime_type, 's', a.size_bytes))
     FROM (SELECT * FROM attachments WHERE owner_type = 'memory' AND owner_id = m.id ORDER BY sort_order) a) AS photos
FROM memories m
WHERE m.deleted_at IS NULL
ORDER BY m.memory_date DESC, m.created_at DESC
''';

  @override
  Stream<List<Memory>> watchAll() => _db
      .customSelect(_sql, readsFrom: {_db.memories, _db.memoryPersonRelations, _db.persons, _db.entityTagRelations, _db.tags, _db.attachments})
      .watch()
      .asyncMap((rows) async => [for (final row in rows) _toDomain(await _db.memories.mapFromRow(row), row)]);

  Memory _toDomain(MemoryRow r, QueryRow row) => Memory(
        id: r.id,
        title: r.title,
        body: r.body,
        date: LocalDate.parse(r.memoryDate),
        eventId: r.eventId,
        category: r.category,
        personIds: (row.readNullable<String>('person_ids') ?? '').split(',').where((s) => s.isNotEmpty).toList(),
        tags: (jsonDecode(row.readNullable<String>('tag_names') ?? '[]') as List<dynamic>).whereType<String>().toList()..sort(),
        photos: [
          for (final p in (jsonDecode(row.readNullable<String>('photos') ?? '[]') as List<dynamic>).cast<Map<String, dynamic>>())
            if (p['id'] != null)
              MemoryPhoto(id: p['id'] as String, relativePath: p['p'] as String, mimeType: p['m'] as String, sizeBytes: p['s'] as int),
        ],
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true).toLocal(),
      );

  @override
  Stream<List<String>> watchTagNames() => (_db.select(_db.tags)..orderBy([(t) => OrderingTerm.asc(t.name)]))
      .watch()
      .map((rows) => [for (final r in rows) r.name]);

  @override
  Future<void> save(Memory memory) async {
    if (memory.title.trim().isEmpty) throw ArgumentError('Title is required');
    final removedFiles = <String>[];
    await _db.transaction(() async {
      final now = nowUtcMs();
      final existing = await (_db.select(_db.memories)..where((t) => t.id.equals(memory.id))).getSingleOrNull();
      final eventOk = memory.eventId == null ||
          await (_db.select(_db.events)..where((t) => t.id.equals(memory.eventId!) & t.deletedAt.isNull())).getSingleOrNull() != null;
      await _db.into(_db.memories).insertOnConflictUpdate(MemoriesCompanion.insert(
            id: memory.id,
            ownerProfileId: existing?.ownerProfileId ?? _profileId,
            title: memory.title.trim(),
            body: Value(memory.body),
            memoryDate: memory.date.toIso(),
            eventId: Value(eventOk ? memory.eventId : null),
            category: Value(memory.category?.trim().isEmpty ?? true ? null : memory.category!.trim()),
            createdAt: existing?.createdAt ?? memory.createdAt.toUtc().millisecondsSinceEpoch,
            updatedAt: now,
            rowVersion: Value((existing?.rowVersion ?? 0) + 1),
          ));

      await (_db.delete(_db.memoryPersonRelations)..where((t) => t.memoryId.equals(memory.id))).go();
      for (final pid in memory.personIds.toSet()) {
        final ok = await (_db.select(_db.persons)..where((t) => t.id.equals(pid) & t.deletedAt.isNull())).getSingleOrNull();
        if (ok != null) {
          await _db.into(_db.memoryPersonRelations).insert(MemoryPersonRelationsCompanion.insert(memoryId: memory.id, personId: pid));
        }
      }

      await (_db.delete(_db.entityTagRelations)..where((t) => t.entityType.equals('memory') & t.entityId.equals(memory.id))).go();
      final seen = <String>{};
      for (final raw in memory.tags) {
        final name = raw.trim();
        if (name.isEmpty || !seen.add(name.toLowerCase())) continue;
        final tag = await (_db.select(_db.tags)..where((t) => t.name.lower().equals(name.toLowerCase()))).getSingleOrNull();
        final tagId = tag?.id ?? const Uuid().v4();
        if (tag == null) {
          await _db.into(_db.tags).insert(TagsCompanion.insert(id: tagId, name: name, createdAt: now, updatedAt: now));
        }
        await _db.into(_db.entityTagRelations).insert(
              EntityTagRelationsCompanion.insert(tagId: tagId, entityType: 'memory', entityId: memory.id),
              mode: InsertMode.insertOrIgnore,
            );
      }

      final current = await (_db.select(_db.attachments)
            ..where((t) => t.ownerType.equals('memory') & t.ownerId.equals(memory.id)))
          .get();
      final keep = {for (final p in memory.photos) p.id};
      for (final a in current) {
        if (!keep.contains(a.id)) {
          await (_db.delete(_db.attachments)..where((t) => t.id.equals(a.id))).go();
          removedFiles.add(a.relativePath);
        }
      }
      for (final (i, p) in memory.photos.indexed) {
        await _db.into(_db.attachments).insertOnConflictUpdate(AttachmentsCompanion.insert(
              id: p.id,
              ownerType: 'memory',
              ownerId: memory.id,
              relativePath: p.relativePath,
              mimeType: p.mimeType,
              sizeBytes: p.sizeBytes,
              sortOrder: Value(i),
              createdAt: now,
            ));
      }
      await _pruneUnusedTags();
    });
    await _deleteFiles(removedFiles);
  }

  @override
  Future<void> delete(String id) async {
    final files = <String>[];
    await _db.transaction(() async {
      final now = nowUtcMs();
      await (_db.update(_db.memories)..where((t) => t.id.equals(id))).write(MemoriesCompanion.custom(
            deletedAt: Constant(now),
            updatedAt: Constant(now),
            rowVersion: _db.memories.rowVersion + const Constant(1),
          ));
      final atts = await (_db.select(_db.attachments)..where((t) => t.ownerType.equals('memory') & t.ownerId.equals(id))).get();
      files.addAll(atts.map((a) => a.relativePath));
      await (_db.delete(_db.attachments)..where((t) => t.ownerType.equals('memory') & t.ownerId.equals(id))).go();
      await (_db.delete(_db.entityTagRelations)..where((t) => t.entityType.equals('memory') & t.entityId.equals(id))).go();
      await _pruneUnusedTags();
    });
    await _deleteFiles(files);
  }

  Future<void> _pruneUnusedTags() =>
      _db.customStatement('DELETE FROM tags WHERE id NOT IN (SELECT tag_id FROM entity_tag_relations)');

  Future<void> _deleteFiles(List<String> paths) async {
    for (final p in paths) {
      try {
        await _files.delete(p);
      } catch (e) {
        debugPrint('Could not delete attachment $p: $e');
      }
    }
  }
}
