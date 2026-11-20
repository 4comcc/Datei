import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/time_engine/local_date.dart';
import '../domain/milestone.dart';

class DriftMilestonesRepository implements MilestonesRepository {
  DriftMilestonesRepository(this._db, this._profileId);
  final AppDatabase _db;
  final String _profileId;

  @override
  Stream<List<Milestone>> watchAll() => (_db.select(_db.milestones)
        ..where((t) => t.deletedAt.isNull())
        ..orderBy([(t) => OrderingTerm.desc(t.milestoneDate)]))
      .watch()
      .map((rows) => [
            for (final r in rows)
              Milestone(
                id: r.id,
                title: r.title,
                description: r.description,
                date: LocalDate.parse(r.milestoneDate),
                kind: MilestoneKind.values.asNameMap()[r.kind] ?? MilestoneKind.custom,
                personId: r.personId,
                projectId: r.projectId,
                eventId: r.eventId,
                createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true).toLocal(),
              ),
          ]);

  Future<bool> _exists(TableInfo<Table, dynamic> table, GeneratedColumn<String> id, GeneratedColumn<int>? deletedAt, String? value) async {
    if (value == null) return false;
    final q = _db.selectOnly(table)..addColumns([id])..where(id.equals(value));
    if (deletedAt != null) q.where(deletedAt.isNull());
    return (await q.getSingleOrNull()) != null;
  }

  @override
  Future<void> save(Milestone m) => _db.transaction(() async {
        if (m.title.trim().isEmpty) throw ArgumentError('Title is required');
        final now = nowUtcMs();
        final existing = await (_db.select(_db.milestones)..where((t) => t.id.equals(m.id))).getSingleOrNull();
        await _db.into(_db.milestones).insertOnConflictUpdate(MilestonesCompanion.insert(
              id: m.id,
              ownerProfileId: existing?.ownerProfileId ?? _profileId,
              title: m.title.trim(),
              description: Value(m.description),
              milestoneDate: m.date.toIso(),
              kind: Value(m.kind.name),
              personId: Value(await _exists(_db.persons, _db.persons.id, _db.persons.deletedAt, m.personId) ? m.personId : null),
              projectId: Value(await _exists(_db.projects, _db.projects.id, _db.projects.deletedAt, m.projectId) ? m.projectId : null),
              eventId: Value(await _exists(_db.events, _db.events.id, _db.events.deletedAt, m.eventId) ? m.eventId : null),
              createdAt: existing?.createdAt ?? m.createdAt.toUtc().millisecondsSinceEpoch,
              updatedAt: now,
              rowVersion: Value((existing?.rowVersion ?? 0) + 1),
            ));
      });

  @override
  Future<void> delete(String id) async {
    final now = nowUtcMs();
    await (_db.update(_db.milestones)..where((t) => t.id.equals(id))).write(MilestonesCompanion.custom(
          deletedAt: Constant(now),
          updatedAt: Constant(now),
          rowVersion: _db.milestones.rowVersion + const Constant(1),
        ));
  }
}
