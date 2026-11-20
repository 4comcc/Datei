import 'package:datei/core/recurrence_engine/recurrence.dart';
import 'package:datei/core/time_engine/time_engine.dart';
import 'package:datei/features/agenda/agenda.dart';
import 'package:datei/features/events/domain/event.dart';
import 'package:datei/features/memories/domain/memory.dart';
import 'package:datei/features/milestones/domain/milestone.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/projects/domain/project.dart';
import 'package:datei/features/timeline/domain/timeline.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const service = TimelineService(AgendaService(TimeEngine(), RecurrenceEngine()));
  final today = LocalDate.parse('2026-11-20');
  final created = DateTime(2026);
  LocalDate d(String s) => LocalDate.parse(s);

  final sara = Person(id: 'sara', fullName: 'Sara', birthDate: d('1996-11-24'), createdAt: created);
  final noor = Person(id: 'noor', fullName: 'Noor', birthDate: d('2000-03-01'), birthYearKnown: false, createdAt: created);
  final events = [
    DateiEvent(id: 'wed', title: 'Wedding', typeId: EventType.family.id, date: d('2015-06-10'), personIds: const ['sara'], createdAt: created),
    DateiEvent(
      id: 'gym', title: 'Gym', typeId: EventType.personal.id, date: d('2020-01-06'),
      recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.weekly), createdAt: created,
    ),
    DateiEvent(id: 'x', title: 'Cancelled trip', typeId: EventType.travel.id, date: d('2026-05-01'), status: EventStatus.cancelled, createdAt: created),
  ];
  final memories = [
    Memory(id: 'm1', title: 'Beach day', date: d('2010-08-01'), personIds: const ['sara'], createdAt: created),
    Memory(id: 'm2', title: 'Old photo', date: d('1999-01-01'), createdAt: created),
  ];
  final milestones = [
    Milestone(id: 'g', title: 'Graduated', date: d('2018-06-30'), kind: MilestoneKind.graduation, personId: 'sara', createdAt: created),
  ];
  final projects = [
    Project(id: 'p', name: 'Book', startDate: d('2026-01-10'), dueDate: d('2027-03-01'), personIds: const ['sara'], createdAt: created),
  ];

  List<TimelineEntry> run(TimelinePeriod period, {Set<TimelineGroup>? groups, String? person}) => service.build(
        today: today,
        period: period,
        people: [sara, noor],
        events: events,
        memories: memories,
        milestones: milestones,
        projects: projects,
        groups: groups ?? {...TimelineGroup.values},
        personId: person,
      );

  test('"All" keeps every one-off item, newest first; cancelled events are skipped', () {
    final all = run(TimelinePeriod.all);
    for (var i = 1; i < all.length; i++) {
      expect(all[i].date.isAfter(all[i - 1].date), isFalse);
    }
    final titles = all.map((e) => e.title).toSet();
    expect(titles, containsAll(['Wedding', 'Beach day', 'Old photo', 'Graduated', 'Book', 'Sara']));
    expect(titles.contains('Cancelled trip'), isFalse);
  });

  test('frequent series show only their start and next occurrence; yearly ones every year', () {
    final gym = run(TimelinePeriod.all).where((e) => e.title == 'Gym').map((e) => e.date).toList();
    expect(gym, [d('2026-11-23'), d('2020-01-06')]); // next Monday, and where the series began
  });

  test('birth entry only when the year is known; birthdays within the window', () {
    final all = run(TimelinePeriod.all, groups: {TimelineGroup.birthdays});
    expect(all.where((e) => e.kind == TimelineKind.birth).map((e) => e.title), ['Sara']);
    final upcomingBirthdays = run(TimelinePeriod.upcoming, groups: {TimelineGroup.birthdays});
    expect(upcomingBirthdays.first.title, 'Noor'); // next March is the latest upcoming
    expect(upcomingBirthdays.firstWhere((e) => e.title == 'Sara').turningAge, 30);
    expect(upcomingBirthdays.firstWhere((e) => e.title == 'Noor').turningAge, isNull);
  });

  test('periods: past year and upcoming', () {
    final past = run(TimelinePeriod.pastYear, groups: {TimelineGroup.projects});
    expect(past.single.kind, TimelineKind.projectStart);
    final upcoming = run(TimelinePeriod.upcoming, groups: {TimelineGroup.projects});
    expect(upcoming.single.kind, TimelineKind.projectDue);
  });

  test('person timeline only includes their items', () {
    final saraLine = run(TimelinePeriod.all, person: 'sara');
    final kinds = saraLine.map((e) => e.kind).toSet();
    expect(kinds, containsAll([TimelineKind.birth, TimelineKind.event, TimelineKind.memory, TimelineKind.milestone, TimelineKind.projectStart]));
    expect(saraLine.any((e) => e.title == 'Old photo' || e.title == 'Gym' || e.title == 'Noor'), isFalse);
  });

  test('group filter', () {
    expect(run(TimelinePeriod.all, groups: {TimelineGroup.memories}).map((e) => e.title), ['Beach day', 'Old photo']);
    expect(run(TimelinePeriod.all, groups: const {}), isEmpty);
  });
}
