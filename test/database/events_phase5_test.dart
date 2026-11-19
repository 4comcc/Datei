import 'package:datei/app/bootstrap.dart';
import 'package:datei/core/database/app_database.dart';
import 'package:datei/core/recurrence_engine/recurrence.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/events/data/drift_events_repository.dart';
import 'package:datei/features/events/domain/event.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late DriftEventsRepository events;
  late DriftEventTypesRepository types;
  LocalDate d(String s) => LocalDate.parse(s);

  DateiEvent ev(String id, {String date = '2026-11-05', RecurrenceRule? rule, String? end, String? time}) => DateiEvent(
        id: id,
        title: 'E $id',
        typeId: EventType.appointment.id,
        date: d(date),
        endDate: end == null ? null : d(end),
        time: time,
        recurrence: rule,
        createdAt: DateTime(2026),
      );

  Future<DateiEvent> load(String id) async => (await events.watchAll().first).firstWhere((e) => e.id == id);

  setUp(() async {
    db = openTestDatabase();
    final profile = await ensureLocalProfile(db);
    events = DriftEventsRepository(db, profile);
    types = DriftEventTypesRepository(db);
  });
  tearDown(() => db.close());

  test('rules roundtrip: weekly weekdays, monthly nth weekday, until and count', () async {
    final weekly = RecurrenceRule(frequency: RecurrenceFrequency.weekly, interval: 2, weekdays: {1, 4}, until: d('2027-01-01'));
    const monthly = RecurrenceRule(frequency: RecurrenceFrequency.monthly, setPos: -1, weekdays: {5}, count: 12);
    const skip = RecurrenceRule(frequency: RecurrenceFrequency.monthly, overflow: MonthOverflow.skip);
    await events.save(ev('w', rule: weekly));
    await events.save(ev('m', rule: monthly));
    await events.save(ev('s', date: '2026-01-31', rule: skip));
    expect((await load('w')).recurrence, weekly);
    expect((await load('m')).recurrence, monthly);
    expect((await load('s')).recurrence, skip);
  });

  test('multi-day events keep their end; end before start is rejected', () async {
    await events.save(ev('trip', end: '2026-11-08', time: '09:00'));
    final e = await load('trip');
    expect(e.endDate, d('2026-11-08'));
    expect(e.spanDays, 3);
    expect(() => events.save(ev('bad', end: '2026-11-01')), throwsArgumentError);
  });

  test('override and cancel single occurrences; replacing an exception', () async {
    await events.save(ev('w', rule: const RecurrenceRule(frequency: RecurrenceFrequency.weekly)));
    await events.overrideOccurrence('w', d('2026-11-12'), OccurrenceOverride(title: 'Moved', date: d('2026-11-13')));
    await events.cancelOccurrence('w', d('2026-11-19'));
    var e = await load('w');
    expect(e.exceptions, hasLength(2));
    final o = e.exceptions.firstWhere((x) => !x.isCancelled).override!;
    expect(o.title, 'Moved');
    expect(o.date, d('2026-11-13'));

    // A new decision for the same occurrence replaces the old one.
    await events.cancelOccurrence('w', d('2026-11-12'));
    e = await load('w');
    expect(e.exceptions.where((x) => x.originalDate == d('2026-11-12')).single.isCancelled, isTrue);
  });

  test('turning recurrence off removes the rule and its exceptions', () async {
    await events.save(ev('w', rule: const RecurrenceRule(frequency: RecurrenceFrequency.weekly)));
    await events.cancelOccurrence('w', d('2026-11-12'));
    await events.save(ev('w'));
    final e = await load('w');
    expect(e.recurrence, isNull);
    expect(e.exceptions, isEmpty);
    expect(await db.select(db.recurrenceRules).get(), isEmpty);
  });

  test('split "this and following" with a counted series and a replacement', () async {
    await events.save(ev('c', date: '2026-11-01', rule: const RecurrenceRule(frequency: RecurrenceFrequency.daily, count: 10)));
    await events.cancelOccurrence('c', d('2026-11-02'));
    await events.cancelOccurrence('c', d('2026-11-06'));
    final replacement = ev('c2', date: '2026-11-04', rule: const RecurrenceRule(frequency: RecurrenceFrequency.daily, count: 10));
    await events.splitSeries('c', d('2026-11-04'), replacement: replacement);

    final old = await load('c');
    expect(old.recurrence!.until, d('2026-11-03'));
    expect(old.recurrence!.count, isNull);
    expect(old.exceptions.map((x) => x.originalDate), [d('2026-11-02')]); // later exceptions dropped
    final next = await load('c2');
    expect(next.recurrence!.count, 7); // unchanged rule → remaining occurrences carried over
  });

  test('split at the first occurrence deletes the original series', () async {
    await events.save(ev('y', rule: const RecurrenceRule.yearly()));
    await events.splitSeries('y', d('2026-11-05'));
    expect((await events.watchAll().first).where((e) => e.id == 'y'), isEmpty);
  });

  test('custom event types: create, rename, delete moves events to Other', () async {
    final t = await types.create('Football', color: 0xFF3F6F7A);
    await types.rename(t.id, 'Padel');
    expect((await types.watchAll().first).last.name, 'Padel');
    await events.save(DateiEvent(id: 'p', title: 'Match', typeId: t.id, date: d('2026-11-21'), createdAt: DateTime(2026)));
    await types.delete(t.id);
    expect((await load('p')).typeId, EventType.other.id);
    await types.delete(EventType.travel.id); // built-in: ignored
    expect((await types.watchAll().first).where((x) => x.id == EventType.travel.id), hasLength(1));
  });

  test('unknown type ids fall back to Other on save', () async {
    await events.save(DateiEvent(id: 'x', title: 'X', typeId: 'missing', date: d('2026-11-21'), createdAt: DateTime(2026)));
    expect((await load('x')).typeId, EventType.other.id);
  });
}
