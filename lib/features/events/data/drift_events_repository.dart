import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/seed_data.dart';
import '../../../core/time_engine/local_date.dart';
import '../domain/event.dart';
import '../domain/events_repository.dart';

class DriftEventsRepository implements EventsRepository {
  DriftEventsRepository(this._db, this._profileId);
  final AppDatabase _db;
  final String _profileId;

  static const _selectSql = '''
SELECT e.*, t.system_key AS type_key, rr.freq AS freq,
  (SELECT group_concat(r.person_id) FROM event_person_relations r
     JOIN persons p ON p.id = r.person_id AND p.deleted_at IS NULL
    WHERE r.event_id = e.id) AS person_ids
FROM events e
JOIN event_types t ON t.id = e.event_type_id
LEFT JOIN recurrence_rules rr ON rr.id = e.recurrence_rule_id
WHERE e.deleted_at IS NULL
ORDER BY e.start_date, e.start_time
''';

  @override
  Stream<List<DateiEvent>> watchAll() => _db
      .customSelect(_selectSql, readsFrom: {
        _db.events,
        _db.eventTypes,
        _db.recurrenceRules,
        _db.eventPersonRelations,
        _db.persons,
      })
      .watch()
      .asyncMap((rows) async => [
            for (final row in rows)
              _toDomain(
                await _db.events.mapFromRow(row),
                typeKey: row.readNullable<String>('type_key'),
                freq: row.readNullable<String>('freq'),
                personIds: row.readNullable<String>('person_ids'),
              ),
          ]);

  DateiEvent _toDomain(EventRow r, {String? typeKey, String? freq, String? personIds}) => DateiEvent(
        id: r.id,
        title: r.title,
        type: EventType.values.asNameMap()[typeKey] ?? EventType.other,
        date: LocalDate.parse(r.startDate),
        time: r.startTime,
        repeatsYearly: freq == 'yearly',
        personIds: (personIds ?? '').split(',').where((s) => s.isNotEmpty).toList(),
        location: r.location,
        notes: r.notes,
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true).toLocal(),
      );

  @override
  Future<void> save(DateiEvent event) => _db.transaction(() async {
        final now = nowUtcMs();
        final existing = await (_db.select(_db.events)..where((t) => t.id.equals(event.id))).getSingleOrNull();

        final oldRuleId = existing?.recurrenceRuleId;
        String? ruleId;
        if (event.repeatsYearly) {
          ruleId = oldRuleId ?? const Uuid().v4();
          await _db.into(_db.recurrenceRules).insertOnConflictUpdate(RecurrenceRulesCompanion.insert(
                id: ruleId,
                freq: 'yearly',
                createdAt: now,
                updatedAt: now,
              ));
        }

        await _db.into(_db.events).insertOnConflictUpdate(EventsCompanion.insert(
              id: event.id,
              ownerProfileId: existing?.ownerProfileId ?? _profileId,
              title: event.title,
              eventTypeId: systemEventTypeId(event.type.name),
              startDate: event.date.toIso(),
              startTime: Value(event.time),
              allDay: Value(event.time == null),
              location: Value(event.location),
              notes: Value(event.notes),
              recurrenceRuleId: Value(ruleId),
              createdAt: existing?.createdAt ?? event.createdAt.toUtc().millisecondsSinceEpoch,
              updatedAt: now,
              rowVersion: Value((existing?.rowVersion ?? 0) + 1),
            ));

        if (oldRuleId != null && ruleId == null) {
          await (_db.delete(_db.recurrenceRules)..where((t) => t.id.equals(oldRuleId))).go();
        }

        await (_db.delete(_db.eventPersonRelations)..where((t) => t.eventId.equals(event.id))).go();
        for (final personId in event.personIds.toSet()) {
          // Skip people that no longer exist (e.g. deleted while the form was open).
          final exists = await (_db.select(_db.persons)
                ..where((t) => t.id.equals(personId) & t.deletedAt.isNull()))
              .getSingleOrNull();
          if (exists == null) continue;
          await _db
              .into(_db.eventPersonRelations)
              .insert(EventPersonRelationsCompanion.insert(eventId: event.id, personId: personId));
        }
      });

  @override
  Future<void> delete(String id) async {
    final now = nowUtcMs();
    await (_db.update(_db.events)..where((t) => t.id.equals(id))).write(
      EventsCompanion.custom(
        deletedAt: Constant(now),
        updatedAt: Constant(now),
        rowVersion: _db.events.rowVersion + const Constant(1),
      ),
    );
  }
}
