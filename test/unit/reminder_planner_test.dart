import 'package:datei/core/notifications/reminder_planner.dart';
import 'package:datei/core/recurrence_engine/recurrence.dart';
import 'package:datei/core/time_engine/time_engine.dart';
import 'package:datei/features/agenda/agenda.dart';
import 'package:datei/features/commitments/domain/commitment.dart';
import 'package:datei/features/events/domain/event.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:flutter_test/flutter_test.dart';

class _Texts implements ReminderTexts {
  @override
  String birthdayTitle(String name, int? turningAge) => 'B:$name:${turningAge ?? '-'}';
  @override
  String commitmentTitle(String name) => 'C:$name';
  @override
  String eventTitle(String title) => 'E:$title';
  @override
  String when(LocalDate date, {String? time, required LocalDate from}) => '${from.daysUntil(date)}d ${time ?? ''}'.trim();
}

void main() {
  const planner = ReminderPlanner(AgendaService(TimeEngine(), RecurrenceEngine()));
  final now = DateTime(2026, 11, 20, 8, 0);
  const on = ReminderSettings(enabled: true, defaultTime: '09:00', birthdayDaysBefore: 1);
  final created = DateTime(2026);

  List<PlannedNotification> run({
    ReminderSettings settings = on,
    List<Person> people = const [],
    List<DateiEvent> events = const [],
    List<Commitment> commitments = const [],
  }) =>
      planner.plan(now: now, settings: settings, people: people, events: events, commitments: commitments, texts: _Texts());

  test('nothing is planned when reminders are off', () {
    expect(run(settings: const ReminderSettings(enabled: false, birthdayDaysBefore: 1), people: [
      Person(id: 'p', fullName: 'Sara', birthDate: LocalDate.parse('1996-11-24'), createdAt: created),
    ]), isEmpty);
  });

  test('birthday reminder the day before at the default time', () {
    final n = run(people: [Person(id: 'p', fullName: 'Sara', birthDate: LocalDate.parse('1996-11-24'), createdAt: created)]).single;
    expect(n.fireAt, DateTime(2026, 11, 23, 9, 0));
    expect(n.title, 'B:Sara:30');
    expect(n.body, '1d');
    expect(n.route, '/people/p');
  });

  test('timed event offsets; past reminders are skipped', () {
    final e = DateiEvent(
      id: 'e',
      title: 'Dentist',
      typeId: EventType.appointment.id,
      date: LocalDate.parse('2026-11-20'),
      time: '10:30',
      reminderMinutes: const [0, 60, 1440],
      createdAt: created,
    );
    final times = run(events: [e]).map((n) => n.fireAt).toList();
    expect(times, [DateTime(2026, 11, 20, 9, 30), DateTime(2026, 11, 20, 10, 30)]); // the day-before one is in the past
  });

  test('all-day events use the default time; recurring routes carry the occurrence', () {
    final e = DateiEvent(
      id: 'w',
      title: 'Bin day',
      typeId: EventType.personal.id,
      date: LocalDate.parse('2026-11-23'),
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.weekly, count: 2),
      reminderMinutes: const [1440],
      createdAt: created,
    );
    final n = run(events: [e]);
    expect(n.map((x) => x.fireAt), [DateTime(2026, 11, 22, 9), DateTime(2026, 11, 29, 9)]);
    expect(n.first.route, '/events/w/edit?occurrence=2026-11-23');
  });

  test('cancelled events and inactive commitments are not reminded', () {
    final e = DateiEvent(
      id: 'e', title: 'X', typeId: EventType.other.id, date: LocalDate.parse('2026-11-25'),
      reminderMinutes: const [0], status: EventStatus.cancelled, createdAt: created,
    );
    final c = Commitment(
      id: 'c', name: 'Old', typeId: CommitmentType.bill.id, expiryDate: LocalDate.parse('2026-11-25'),
      lifecycle: CommitmentLifecycle.completed, reminderDays: const [1], createdAt: created,
    );
    expect(run(events: [e], commitments: [c]), isEmpty);
  });

  test('commitment reminders N days before the due (renew-by) date, within the 60-day window', () {
    final c = Commitment(
      id: 'c', name: 'example.com', typeId: CommitmentType.domain.id,
      expiryDate: LocalDate.parse('2027-03-01'), renewalDate: LocalDate.parse('2026-12-20'),
      reminderDays: const [90, 30, 7, 0], createdAt: created,
    );
    final n = run(commitments: [c]);
    expect(n.map((x) => x.fireAt), [DateTime(2026, 11, 20, 9), DateTime(2026, 12, 13, 9), DateTime(2026, 12, 20, 9)]);
    expect(n.first.title, 'C:example.com');
    expect(n.first.route, '/commitments/c');
  });

  test('sorted, capped, and ids are stable', () {
    final people = [
      for (var i = 0; i < 40; i++)
        Person(id: 'p$i', fullName: 'P$i', birthDate: LocalDate(1990, 12, 1 + (i % 28)), createdAt: created),
    ];
    const small = ReminderPlanner(AgendaService(TimeEngine(), RecurrenceEngine()), maxNotifications: 10);
    final a = small.plan(now: now, settings: on, people: people, events: const [], commitments: const [], texts: _Texts());
    final b = small.plan(now: now, settings: on, people: people, events: const [], commitments: const [], texts: _Texts());
    expect(a, hasLength(10));
    for (var i = 1; i < a.length; i++) {
      expect(a[i].fireAt.isBefore(a[i - 1].fireAt), isFalse);
    }
    expect(a.map((x) => x.id), b.map((x) => x.id));
    expect(ReminderPlanner.stableId('event|e|2026-11-20|60'), ReminderPlanner.stableId('event|e|2026-11-20|60'));
    expect(ReminderPlanner.stableId('a'), isNot(ReminderPlanner.stableId('b')));
  });
}
