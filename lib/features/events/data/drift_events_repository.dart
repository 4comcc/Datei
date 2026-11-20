import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/recurrence_engine/recurrence.dart';
import '../../../core/time_engine/local_date.dart';
import '../domain/event.dart';
import '../domain/events_repository.dart';
import '../domain/series_editing.dart';

class DriftEventsRepository implements EventsRepository {
  DriftEventsRepository(this._db, this._profileId);
  final AppDatabase _db;
  final String _profileId;

  static String _sql(String where) => '''
SELECT e.*,
  rr.freq AS r_freq, rr."interval" AS r_interval, rr.by_weekday AS r_by_weekday, rr.by_month_day AS r_by_month_day,
  rr.by_set_pos AS r_by_set_pos, rr.until_date AS r_until, rr.count AS r_count, rr.overflow_policy AS r_overflow,
  (SELECT group_concat(r.person_id) FROM event_person_relations r
     JOIN persons p ON p.id = r.person_id AND p.deleted_at IS NULL
    WHERE r.event_id = e.id) AS person_ids,
  (SELECT json_group_array(json_object('d', x.original_date, 'k', x.kind, 'o', x.override_json))
     FROM event_exceptions x WHERE x.event_id = e.id) AS exceptions,
  (SELECT group_concat(rm.offset_minutes) FROM reminders rm
    WHERE rm.owner_type = 'event' AND rm.owner_id = e.id) AS reminder_minutes
FROM events e
LEFT JOIN recurrence_rules rr ON rr.id = e.recurrence_rule_id
WHERE e.deleted_at IS NULL $where
ORDER BY e.start_date, e.start_time
''';

  Future<DateiEvent?> _loadOne(String id) async {
    final row = await _db.customSelect(_sql('AND e.id = ?'), variables: [Variable.withString(id)]).getSingleOrNull();
    return row == null ? null : _toDomain(await _db.events.mapFromRow(row), row);
  }

  @override
  Stream<List<DateiEvent>> watchAll() => _db
      .customSelect(_sql(''), readsFrom: {
        _db.events,
        _db.recurrenceRules,
        _db.eventPersonRelations,
        _db.persons,
        _db.eventExceptions,
        _db.reminders,
      })
      .watch()
      .asyncMap((rows) async => [for (final row in rows) _toDomain(await _db.events.mapFromRow(row), row)]);

  DateiEvent _toDomain(EventRow r, QueryRow row) {
    final freq = RecurrenceFrequency.values.asNameMap()[row.readNullable<String>('r_freq')];
    final RecurrenceRule? rule = freq == null
        ? null
        : RecurrenceRule(
            frequency: freq,
            interval: row.readNullable<int>('r_interval') ?? 1,
            weekdays: {
              for (final s in (row.readNullable<String>('r_by_weekday') ?? '').split(',')) ?int.tryParse(s),
            },
            monthDay: row.readNullable<int>('r_by_month_day'),
            setPos: row.readNullable<int>('r_by_set_pos'),
            until: switch (row.readNullable<String>('r_until')) { final s? => LocalDate.parse(s), null => null },
            count: row.readNullable<int>('r_count'),
            overflow: row.readNullable<String>('r_overflow') == 'skip' ? MonthOverflow.skip : MonthOverflow.clampToLastDay,
          );
    final exceptions = <EventException>[
      for (final x in (jsonDecode(row.readNullable<String>('exceptions') ?? '[]') as List<dynamic>).cast<Map<String, dynamic>>())
        if (x['d'] != null)
          x['k'] == 'cancelled'
              ? EventException.cancelled(LocalDate.parse(x['d'] as String))
              : EventException.overridden(
                  LocalDate.parse(x['d'] as String),
                  OccurrenceOverride.fromJson(jsonDecode(x['o'] as String? ?? '{}') as Map<String, dynamic>),
                ),
    ];
    return DateiEvent(
      id: r.id,
      title: r.title,
      typeId: r.eventTypeId,
      date: LocalDate.parse(r.startDate),
      time: r.startTime,
      endDate: r.endDate == null ? null : LocalDate.parse(r.endDate!),
      endTime: r.endTime,
      recurrence: rule,
      exceptions: exceptions,
      personIds: (row.readNullable<String>('person_ids') ?? '').split(',').where((s) => s.isNotEmpty).toList(),
      location: r.location,
      notes: r.notes,
      priority: EventPriority.values.asNameMap()[r.priority] ?? EventPriority.normal,
      status: EventStatus.values.asNameMap()[r.status] ?? EventStatus.planned,
      reminderMinutes: [
        for (final m in (row.readNullable<String>('reminder_minutes') ?? '').split(',')) ?int.tryParse(m),
      ]..sort(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true).toLocal(),
    );
  }

  @override
  Future<void> save(DateiEvent event) => _db.transaction(() => _save(event));

  Future<void> _save(DateiEvent event) async {
    if (event.endDate != null && event.endDate!.isBefore(event.date)) {
      throw ArgumentError('End date must not be before the start date');
    }
    final now = nowUtcMs();
    final existing = await (_db.select(_db.events)..where((t) => t.id.equals(event.id))).getSingleOrNull();
    final typeExists =
        await (_db.select(_db.eventTypes)..where((t) => t.id.equals(event.typeId))).getSingleOrNull() != null;

    final oldRuleId = existing?.recurrenceRuleId;
    String? ruleId;
    final rule = event.recurrence;
    if (rule != null) {
      ruleId = oldRuleId ?? const Uuid().v4();
      await _db.into(_db.recurrenceRules).insertOnConflictUpdate(RecurrenceRulesCompanion.insert(
            id: ruleId,
            freq: rule.frequency.name,
            interval: Value(rule.interval),
            byWeekday: Value(rule.weekdays.isEmpty ? null : (rule.weekdays.toList()..sort()).join(',')),
            byMonthDay: Value(rule.monthDay),
            bySetPos: Value(rule.setPos),
            untilDate: Value(rule.until?.toIso()),
            count: Value(rule.count),
            overflowPolicy: Value(rule.overflow == MonthOverflow.skip ? 'skip' : 'clamp_to_last_day'),
            createdAt: now,
            updatedAt: now,
          ));
    }

    await _db.into(_db.events).insertOnConflictUpdate(EventsCompanion.insert(
          id: event.id,
          ownerProfileId: existing?.ownerProfileId ?? _profileId,
          title: event.title,
          eventTypeId: typeExists ? event.typeId : EventType.other.id,
          startDate: event.date.toIso(),
          startTime: Value(event.time),
          endDate: Value(event.endDate?.toIso()),
          endTime: Value(event.endTime),
          allDay: Value(event.time == null),
          location: Value(event.location),
          notes: Value(event.notes),
          priority: Value(event.priority.name),
          status: Value(event.status.name),
          recurrenceRuleId: Value(ruleId),
          createdAt: existing?.createdAt ?? event.createdAt.toUtc().millisecondsSinceEpoch,
          updatedAt: now,
          rowVersion: Value((existing?.rowVersion ?? 0) + 1),
        ));

    if (oldRuleId != null && ruleId == null) {
      await (_db.delete(_db.recurrenceRules)..where((t) => t.id.equals(oldRuleId))).go();
      await (_db.delete(_db.eventExceptions)..where((t) => t.eventId.equals(event.id))).go();
    }

    await (_db.delete(_db.reminders)..where((t) => t.ownerType.equals('event') & t.ownerId.equals(event.id))).go();
    for (final m in event.reminderMinutes.toSet()) {
      if (m < 0) continue;
      await _db.into(_db.reminders).insert(RemindersCompanion.insert(
            id: const Uuid().v4(),
            ownerType: 'event',
            ownerId: event.id,
            offsetMinutes: m,
            createdAt: now,
            updatedAt: now,
          ));
    }

    await (_db.delete(_db.eventPersonRelations)..where((t) => t.eventId.equals(event.id))).go();
    for (final personId in event.personIds.toSet()) {
      // Skip people that no longer exist (e.g. deleted while the form was open).
      final exists = await (_db.select(_db.persons)..where((t) => t.id.equals(personId) & t.deletedAt.isNull()))
          .getSingleOrNull();
      if (exists == null) continue;
      await _db
          .into(_db.eventPersonRelations)
          .insert(EventPersonRelationsCompanion.insert(eventId: event.id, personId: personId));
    }
  }

  @override
  Future<void> delete(String id) => _db.transaction(() => _delete(id));

  Future<void> _delete(String id) async {
    final now = nowUtcMs();
    await (_db.update(_db.events)..where((t) => t.id.equals(id))).write(
      EventsCompanion.custom(
        deletedAt: Constant(now),
        updatedAt: Constant(now),
        rowVersion: _db.events.rowVersion + const Constant(1),
      ),
    );
    await (_db.delete(_db.reminders)..where((t) => t.ownerType.equals('event') & t.ownerId.equals(id))).go();
    await (_db.update(_db.memories)..where((t) => t.eventId.equals(id)))
        .write(MemoriesCompanion(eventId: const Value(null), updatedAt: Value(now)));
    await (_db.update(_db.milestones)..where((t) => t.eventId.equals(id)))
        .write(MilestonesCompanion(eventId: const Value(null), updatedAt: Value(now)));
    await (_db.delete(_db.projectEventRelations)..where((t) => t.eventId.equals(id))).go();
  }

  Future<void> _putException(String eventId, LocalDate original, String kind, String? json) async {
    final now = nowUtcMs();
    await (_db.delete(_db.eventExceptions)
          ..where((t) => t.eventId.equals(eventId) & t.originalDate.equals(original.toIso())))
        .go();
    await _db.into(_db.eventExceptions).insert(EventExceptionsCompanion.insert(
          id: const Uuid().v4(),
          eventId: eventId,
          originalDate: original.toIso(),
          kind: kind,
          overrideJson: Value(json),
          createdAt: now,
          updatedAt: now,
        ));
  }

  @override
  Future<void> overrideOccurrence(String eventId, LocalDate originalDate, OccurrenceOverride change) =>
      _db.transaction(() => _putException(eventId, originalDate, 'overridden', jsonEncode(change.toJson())));

  @override
  Future<void> cancelOccurrence(String eventId, LocalDate originalDate) =>
      _db.transaction(() => _putException(eventId, originalDate, 'cancelled', null));

  @override
  Future<void> splitSeries(String eventId, LocalDate at, {DateiEvent? replacement}) => _db.transaction(() async {
        final original = await _loadOne(eventId);
        if (original == null || original.recurrence == null) {
          throw StateError('Event $eventId is not a recurring event');
        }
        const editing = SeriesEditing();
        final split = editing.split(original.date, original.recurrence!, at);
        if (split.before == null) {
          await _delete(eventId);
        } else {
          await _save(original.copyWith(recurrence: () => split.before));
          await (_db.delete(_db.eventExceptions)
                ..where((t) => t.eventId.equals(eventId) & t.originalDate.isBiggerOrEqualValue(at.toIso())))
              .go();
        }
        if (replacement != null) {
          // The new series keeps the edited rule; if the user did not change it, carry the remaining count.
          final keepRule = replacement.recurrence == original.recurrence ? split.after : replacement.recurrence;
          await _save(replacement.copyWith(recurrence: () => keepRule));
        }
      });
}

class DriftEventTypesRepository implements EventTypesRepository {
  DriftEventTypesRepository(this._db);
  final AppDatabase _db;

  @override
  Stream<List<EventTypeInfo>> watchAll() => (_db.select(_db.eventTypes)
        ..orderBy([(t) => OrderingTerm.desc(t.isSystem), (t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.createdAt)]))
      .watch()
      .map((rows) => [
            for (final r in rows)
              EventTypeInfo(id: r.id, systemKey: r.systemKey, name: r.name, color: r.color, sortOrder: r.sortOrder),
          ]);

  @override
  Future<EventTypeInfo> create(String name, {int? color}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Type name is required');
    final now = nowUtcMs();
    final id = const Uuid().v4();
    final maxOrder = await (_db.selectOnly(_db.eventTypes)..addColumns([_db.eventTypes.sortOrder.max()]))
        .map((r) => r.read(_db.eventTypes.sortOrder.max()))
        .getSingle();
    final order = (maxOrder ?? 0) + 1;
    await _db.into(_db.eventTypes).insert(EventTypesCompanion.insert(
          id: id,
          name: Value(trimmed),
          color: Value(color),
          sortOrder: Value(order),
          createdAt: now,
          updatedAt: now,
        ));
    return EventTypeInfo(id: id, name: trimmed, color: color, sortOrder: order);
  }

  @override
  Future<void> rename(String id, String name, {int? color}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Type name is required');
    await (_db.update(_db.eventTypes)..where((t) => t.id.equals(id) & t.isSystem.equals(false)))
        .write(EventTypesCompanion(name: Value(trimmed), color: Value(color), updatedAt: Value(nowUtcMs())));
  }

  @override
  Future<void> delete(String id) => _db.transaction(() async {
        final type = await (_db.select(_db.eventTypes)..where((t) => t.id.equals(id))).getSingleOrNull();
        if (type == null || type.isSystem) return;
        await (_db.update(_db.events)..where((t) => t.eventTypeId.equals(id)))
            .write(EventsCompanion(eventTypeId: Value(EventType.other.id), updatedAt: Value(nowUtcMs())));
        await (_db.delete(_db.eventTypes)..where((t) => t.id.equals(id))).go();
      });
}
