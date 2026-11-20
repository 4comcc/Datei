import 'package:datei/app/localization/gen/app_localizations_ar.dart';
import 'package:datei/app/localization/gen/app_localizations_en.dart';
import 'package:datei/core/export/csv.dart';
import 'package:datei/core/recurrence_engine/recurrence.dart';
import 'package:datei/core/time_engine/time_engine.dart';
import 'package:datei/features/agenda/agenda.dart';
import 'package:datei/features/commitments/domain/commitment.dart';
import 'package:datei/features/events/domain/event.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/reports/domain/reports.dart';
import 'package:datei/features/reports/presentation/csv_exports.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = LocalDate.parse('2026-11-20');
  final created = DateTime(2026);
  LocalDate d(String s) => LocalDate.parse(s);
  final people = [
    Person(id: 'a', fullName: 'Child', birthDate: d('2015-01-10'), categoryIds: const ['fam'], createdAt: created),
    Person(id: 'b', fullName: 'Adult', birthDate: d('1990-11-25'), categoryIds: const ['fam', 'work'], createdAt: created),
    Person(id: 'c', fullName: 'No date', createdAt: created),
    Person(id: 'd', fullName: 'Senior', birthDate: d('1950-11-01'), createdAt: created),
  ];

  test('report counts: categories, age buckets, months, upcoming, commitments', () {
    const service = ReportService(AgendaService(TimeEngine(), RecurrenceEngine()), TimeEngine(), CommitmentRules());
    final r = service.build(
      today: today,
      people: people,
      events: [DateiEvent(id: 'e', title: 'E', typeId: EventType.travel.id, date: d('2026-11-22'), createdAt: created)],
      commitments: [Commitment(id: 'c', name: 'C', typeId: CommitmentType.bill.id, expiryDate: d('2026-11-01'), createdAt: created)],
      memories: const [],
      milestones: const [],
    );
    expect(r.peopleCount, 4);
    expect(r.peopleByCategory, {'fam': 2, 'work': 1});
    expect(r.uncategorized, 2);
    expect(r.ageBucketCounts, [1, 0, 1, 0, 1]); // 11, 35, 76
    expect(r.unknownAge, 1);
    expect(r.birthdaysByMonth[0], 1);
    expect(r.birthdaysByMonth[10], 2);
    expect(r.eventsByType, {EventType.travel.id: 1});
    expect(r.upcoming[7], 2); // event on 22nd + Adult's birthday on 25th
    expect(r.commitmentsByStatus[CommitmentStatus.overdue], 1);
  });

  test('CSV: BOM, quoting, CRLF and formula neutralization', () {
    final csv = CsvBuilder(['a', 'b'])
      ..add(['x,y', 'say "hi"'])
      ..add(['=SUM(A1)', '-5'])
      ..add(['line\nbreak', null]);
    final s = csv.toString();
    expect(s.startsWith('\uFEFF'), isTrue);
    expect(s, contains('"x,y","say ""hi"""\r\n'));
    expect(s, contains("'=SUM(A1),-5\r\n")); // numbers stay numbers
    expect(s, contains('"line\nbreak",\r\n'));
  });

  test('people export uses localized headers and hides placeholder birth years', () {
    final x = CsvExports(
      l: AppLocalizationsAr(),
      today: today,
      categoryLabels: const {'fam': 'العائلة'},
      eventTypeLabels: const {},
      personNames: const {},
    );
    final csv = x.people([
      ...people.take(1),
      Person(id: 'n', fullName: 'نور', birthDate: d('2000-02-29'), birthYearKnown: false, createdAt: created),
    ]);
    final lines = csv.split('\r\n');
    expect(lines.first, startsWith('\uFEFFالاسم الكامل,'));
    expect(lines[1], startsWith('Child,,2015-01-10,11,العائلة'));
    expect(lines[2], contains('--02-29'));
  });

  test('events export includes recurrence and linked people', () {
    final x = CsvExports(
      l: AppLocalizationsEn(),
      today: today,
      categoryLabels: const {},
      eventTypeLabels: {EventType.personal.id: 'Personal'},
      personNames: const {'a': 'Child'},
    );
    final csv = x.events([
      DateiEvent(id: 'e', title: 'Gym', typeId: EventType.personal.id, date: d('2026-01-05'), time: '18:00',
          recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.weekly, interval: 2), personIds: const ['a'], createdAt: created),
    ]);
    expect(csv.split('\r\n')[1], startsWith('Gym,Personal,2026-01-05,18:00,,,Every 2 weeks,Child'));
  });
}
