import 'package:datei/core/recurrence_engine/recurrence.dart';
import 'package:datei/core/time_engine/time_engine.dart';
import 'package:datei/features/agenda/agenda.dart';
import 'package:datei/features/events/domain/event.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = AgendaService(TimeEngine(), RecurrenceEngine());
  final created = DateTime(2026);
  final people = [
    Person(id: 'p1', fullName: 'Leap Baby', birthDate: LocalDate.parse('2000-02-29'), createdAt: created),
    Person(id: 'p2', fullName: 'No Birthday', createdAt: created),
  ];
  final events = [
    DateiEvent(id: 'e1', title: 'Wedding', typeId: EventType.anniversary.id, date: LocalDate.parse('2015-03-01'),
        recurrence: const RecurrenceRule.yearly(), createdAt: created),
    DateiEvent(id: 'e2', title: 'Dentist', typeId: EventType.appointment.id, date: LocalDate.parse('2026-02-28'),
        time: '10:30', createdAt: created),
    DateiEvent(id: 'e3', title: 'Old trip', typeId: EventType.travel.id, date: LocalDate.parse('2020-02-28'),
        createdAt: created),
  ];

  test('builds birthdays and events in range, sorted by date then time', () {
    final items = service.itemsInRange(
      people: people,
      events: events,
      from: LocalDate.parse('2026-02-01'),
      to: LocalDate.parse('2026-03-31'),
    );
    expect(items.map((i) => (i.date.toIso(), i.kind)).toList(), [
      ('2026-02-28', AgendaKind.birthday), // leap birthday observed Feb 28
      ('2026-02-28', AgendaKind.event),
      ('2026-03-01', AgendaKind.event),
    ]);
    expect(items.first.turningAge, 26);
  });

  test('birth date itself is not a birthday occurrence', () {
    final items = service.itemsInRange(
      people: people,
      events: const [],
      from: LocalDate.parse('2000-01-01'),
      to: LocalDate.parse('2000-12-31'),
    );
    expect(items, isEmpty);
  });

  group('recurrence, exceptions and multi-day', () {
    DateiEvent weekly({List<EventException> ex = const []}) => DateiEvent(
          id: 'w',
          title: 'Class',
          typeId: EventType.personal.id,
          date: LocalDate.parse('2026-11-05'),
          time: '18:00',
          recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.weekly),
          exceptions: ex,
          createdAt: created,
        );

    test('cancelled occurrences are skipped; overrides change title, time and day', () {
      final e = weekly(ex: [
        EventException.cancelled(LocalDate.parse('2026-11-12')),
        EventException.overridden(LocalDate.parse('2026-11-19'),
            OccurrenceOverride(title: 'Exam', date: LocalDate.parse('2026-11-21'), time: '10:00')),
      ]);
      final items = service.eventOccurrences(e, LocalDate.parse('2026-11-01'), LocalDate.parse('2026-11-30')).toList();
      expect(items.map((i) => i.date.toIso()), ['2026-11-05', '2026-11-21', '2026-11-26']);
      final moved = items[1];
      expect(moved.title, 'Exam');
      expect(moved.time, '10:00');
      expect(moved.occurrenceDate, LocalDate.parse('2026-11-19'));
    });

    test('an occurrence moved into the window from outside it is found', () {
      final e = weekly(ex: [
        EventException.overridden(LocalDate.parse('2026-12-03'), OccurrenceOverride(date: LocalDate.parse('2026-11-28'))),
      ]);
      final items = service.eventOccurrences(e, LocalDate.parse('2026-11-27'), LocalDate.parse('2026-11-29')).toList();
      expect(items.single.occurrenceDate, LocalDate.parse('2026-12-03'));
    });

    test('multi-day events cover every day of their span and show while ongoing', () {
      final trip = DateiEvent(
        id: 't',
        title: 'Trip',
        typeId: EventType.travel.id,
        date: LocalDate.parse('2026-11-17'),
        endDate: LocalDate.parse('2026-11-21'),
        createdAt: created,
      );
      final today = LocalDate.parse('2026-11-19');
      final items = service.itemsInRange(people: const [], events: [trip], from: today, to: today);
      expect(items.single.coversDay(today), isTrue);
      expect(items.single.endDate, LocalDate.parse('2026-11-21'));
      expect(service.nextOccurrence(trip, today)?.date, LocalDate.parse('2026-11-17'));
    });

    test('nextOccurrence finds the next instance of a series', () {
      expect(service.nextOccurrence(weekly(), LocalDate.parse('2026-11-20'))!.date, LocalDate.parse('2026-11-26'));
    });
  });
}
