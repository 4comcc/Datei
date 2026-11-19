import 'package:datei/core/time_engine/time_engine.dart';
import 'package:datei/features/agenda/agenda.dart';
import 'package:datei/features/events/domain/event.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = AgendaService(TimeEngine());
  final created = DateTime(2026);
  final people = [
    Person(id: 'p1', fullName: 'Leap Baby', birthDate: LocalDate.parse('2000-02-29'), createdAt: created),
    Person(id: 'p2', fullName: 'No Birthday', createdAt: created),
  ];
  final events = [
    DateiEvent(id: 'e1', title: 'Wedding', type: EventType.anniversary, date: LocalDate.parse('2015-03-01'),
        repeatsYearly: true, createdAt: created),
    DateiEvent(id: 'e2', title: 'Dentist', type: EventType.appointment, date: LocalDate.parse('2026-02-28'),
        time: '10:30', createdAt: created),
    DateiEvent(id: 'e3', title: 'Old trip', type: EventType.travel, date: LocalDate.parse('2020-02-28'),
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
}
