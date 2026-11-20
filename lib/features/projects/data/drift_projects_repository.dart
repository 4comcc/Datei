import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/time_engine/local_date.dart';
import '../../events/domain/event.dart' show EventPriority;
import '../domain/project.dart';

class DriftProjectsRepository implements ProjectsRepository {
  DriftProjectsRepository(this._db, this._profileId);
  final AppDatabase _db;
  final String _profileId;

  static const _sql = '''
SELECT pr.*,
  (SELECT group_concat(r.person_id) FROM project_person_relations r
     JOIN persons p ON p.id = r.person_id AND p.deleted_at IS NULL WHERE r.project_id = pr.id) AS person_ids,
  (SELECT group_concat(r.event_id) FROM project_event_relations r
     JOIN events e ON e.id = r.event_id AND e.deleted_at IS NULL WHERE r.project_id = pr.id) AS event_ids
FROM projects pr
WHERE pr.deleted_at IS NULL
ORDER BY CASE pr.status WHEN 'done' THEN 1 WHEN 'cancelled' THEN 1 ELSE 0 END, COALESCE(pr.due_date, '9999'), pr.name
''';

  List<String> _ids(String? csv) => (csv ?? '').split(',').where((s) => s.isNotEmpty).toList();

  @override
  Stream<List<Project>> watchAll() => _db
      .customSelect(_sql, readsFrom: {_db.projects, _db.projectPersonRelations, _db.projectEventRelations, _db.persons, _db.events})
      .watch()
      .asyncMap((rows) async {
        final out = <Project>[];
        for (final row in rows) {
          final r = await _db.projects.mapFromRow(row);
          out.add(Project(
            id: r.id,
            name: r.name,
            description: r.description,
            startDate: r.startDate == null ? null : LocalDate.parse(r.startDate!),
            dueDate: r.dueDate == null ? null : LocalDate.parse(r.dueDate!),
            status: ProjectStatus.values.asNameMap()[r.status] ?? ProjectStatus.planned,
            priority: EventPriority.values.asNameMap()[r.priority] ?? EventPriority.normal,
            notes: r.notes,
            personIds: _ids(row.readNullable<String>('person_ids')),
            eventIds: _ids(row.readNullable<String>('event_ids')),
            createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true).toLocal(),
          ));
        }
        return out;
      });

  @override
  Future<void> save(Project p) => _db.transaction(() async {
        if (p.name.trim().isEmpty) throw ArgumentError('Name is required');
        if (p.startDate != null && p.dueDate != null && p.dueDate!.isBefore(p.startDate!)) {
          throw ArgumentError('Due date must not be before the start date');
        }
        final now = nowUtcMs();
        final existing = await (_db.select(_db.projects)..where((t) => t.id.equals(p.id))).getSingleOrNull();
        await _db.into(_db.projects).insertOnConflictUpdate(ProjectsCompanion.insert(
              id: p.id,
              ownerProfileId: existing?.ownerProfileId ?? _profileId,
              name: p.name.trim(),
              description: Value(p.description),
              startDate: Value(p.startDate?.toIso()),
              dueDate: Value(p.dueDate?.toIso()),
              status: Value(p.status.name),
              priority: Value(p.priority.name),
              notes: Value(p.notes),
              createdAt: existing?.createdAt ?? p.createdAt.toUtc().millisecondsSinceEpoch,
              updatedAt: now,
              rowVersion: Value((existing?.rowVersion ?? 0) + 1),
            ));
        await (_db.delete(_db.projectPersonRelations)..where((t) => t.projectId.equals(p.id))).go();
        for (final id in p.personIds.toSet()) {
          if (await (_db.select(_db.persons)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull() != null) {
            await _db.into(_db.projectPersonRelations).insert(ProjectPersonRelationsCompanion.insert(projectId: p.id, personId: id));
          }
        }
        await (_db.delete(_db.projectEventRelations)..where((t) => t.projectId.equals(p.id))).go();
        for (final id in p.eventIds.toSet()) {
          if (await (_db.select(_db.events)..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull() != null) {
            await _db.into(_db.projectEventRelations).insert(ProjectEventRelationsCompanion.insert(projectId: p.id, eventId: id));
          }
        }
      });

  @override
  Future<void> delete(String id) => _db.transaction(() async {
        final now = nowUtcMs();
        await (_db.update(_db.projects)..where((t) => t.id.equals(id))).write(ProjectsCompanion.custom(
              deletedAt: Constant(now),
              updatedAt: Constant(now),
              rowVersion: _db.projects.rowVersion + const Constant(1),
            ));
        await (_db.update(_db.milestones)..where((t) => t.projectId.equals(id)))
            .write(MilestonesCompanion(projectId: const Value(null), updatedAt: Value(now)));
      });
}
