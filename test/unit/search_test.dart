import 'package:datei/core/recurrence_engine/recurrence.dart';
import 'package:datei/core/time_engine/time_engine.dart';
import 'package:datei/core/utils/text_normalize.dart';
import 'package:datei/features/agenda/agenda.dart';
import 'package:datei/features/commitments/domain/commitment.dart';
import 'package:datei/features/events/domain/event.dart';
import 'package:datei/features/memories/domain/memory.dart';
import 'package:datei/features/milestones/domain/milestone.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/projects/domain/project.dart';
import 'package:datei/features/search/domain/search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Arabic-aware normalization', () {
    expect(normalizeForSearch('أحمد'), normalizeForSearch('احمد'));
    expect(normalizeForSearch('إيمان'), 'ايمان');
    expect(normalizeForSearch('مدرسة'), normalizeForSearch('مدرسه'));
    expect(normalizeForSearch('مصطفى'), normalizeForSearch('مصطفي'));
    expect(normalizeForSearch('مُحَمَّد'), 'محمد');
    expect(normalizeForSearch('عــلي'), 'علي');
    expect(normalizeForSearch('٢٠٢٦'), '2026');
    expect(normalizeForSearch('  Hello   World '), 'hello world');
  });

  const engine = SearchEngine(AgendaService(TimeEngine(), RecurrenceEngine()), TimeEngine(), CommitmentRules());
  final today = LocalDate.parse('2026-11-20');
  final created = DateTime(2026);
  LocalDate d(String s) => LocalDate.parse(s);

  final data = SearchData(
    people: [
      Person(id: 'p1', fullName: 'أحمد علي', occupation: 'مهندس', birthDate: d('1990-12-05'), categoryIds: const ['fam'], createdAt: created),
      Person(id: 'p2', fullName: 'Sara Ahmed', birthDate: d('2010-03-01'), createdAt: created),
    ],
    events: [
      DateiEvent(id: 'e1', title: 'Meeting with Ahmed', typeId: EventType.appointment.id, date: d('2026-11-25'),
          priority: EventPriority.high, personIds: const ['p1'], createdAt: created),
      DateiEvent(id: 'e2', title: 'Old trip', typeId: EventType.travel.id, date: d('2020-05-01'), createdAt: created),
      DateiEvent(id: 'e3', title: 'Gym', typeId: EventType.personal.id, date: d('2026-01-05'),
          recurrence: const RecurrenceRule(frequency: RecurrenceFrequency.weekly), createdAt: created),
    ],
    commitments: [
      Commitment(id: 'c1', name: 'datei.app', typeId: CommitmentType.domain.id, expiryDate: d('2026-11-10'), providerName: 'Namecheap', createdAt: created),
      Commitment(id: 'c2', name: 'Car insurance', typeId: CommitmentType.insurance.id, expiryDate: d('2027-05-01'), createdAt: created),
    ],
    memories: [
      Memory(id: 'm1', title: 'رحلة الإسكندرية', date: d('2019-08-01'), tags: const ['سفر'], personIds: const ['p1'], createdAt: created),
    ],
    milestones: [Milestone(id: 'g1', title: 'Graduation', date: d('2012-06-01'), personId: 'p2', createdAt: created)],
    projects: [Project(id: 'pr', name: 'Write a book', dueDate: d('2026-10-01'), createdAt: created)],
  );

  List<String> ids(SearchQuery q) => engine.search(q, data, today).map((r) => r.id).toList();

  test('text search across all types; title matches rank first', () {
    // Both titles contain the word (same score); ties go to the date closest to today.
    expect(ids(const SearchQuery(text: 'ahmed')), ['e1', 'p2']);
    expect(ids(const SearchQuery(text: 'احمد')), ['p1']); // hamza-insensitive
    expect(ids(const SearchQuery(text: 'namecheap')), ['c1']); // provider field
    expect(ids(const SearchQuery(text: 'الاسكندريه')), ['m1']); // alef + ta marbuta
    expect(ids(const SearchQuery(text: 'سفر')), ['m1']); // tag
  });

  test('type filter', () {
    expect(ids(const SearchQuery(text: 'a', types: {SearchEntityType.commitment})).toSet(), {'c1', 'c2'});
  });

  test('time state conditions', () {
    expect(ids(const SearchQuery(conditions: [TimeStateCondition(TimeState.overdue)])).toSet(), {'c1', 'pr', 'e2'});
    expect(ids(const SearchQuery(types: {SearchEntityType.event}, conditions: [TimeStateCondition(TimeState.upcoming)])).toSet(), {'e1', 'e3'});
    expect(ids(const SearchQuery(conditions: [RecurringCondition()])), ['e3']);
  });

  test('match all (AND) vs match any (OR)', () {
    const both = [PersonCondition('p1'), PriorityCondition(EventPriority.high)];
    expect(ids(const SearchQuery(conditions: both)), ['e1']);
    expect(ids(const SearchQuery(conditions: both, matchAll: false)).toSet(), {'p1', 'e1', 'm1'});
  });

  test('date range, age, category and tag conditions', () {
    final dec = DateRangeCondition(from: d('2026-12-01'), to: d('2026-12-31'));
    expect(ids(SearchQuery(types: const {SearchEntityType.person}, conditions: [dec])), ['p1']); // birthday in December
    expect(ids(const SearchQuery(conditions: [AgeRangeCondition(min: 30)])), ['p1']);
    expect(ids(const SearchQuery(conditions: [CategoryCondition('fam')])), ['p1']);
    expect(ids(const SearchQuery(conditions: [TagCondition('سفر')])), ['m1']);
  });

  test('saved query JSON roundtrip (text not saved)', () {
    final q = SearchQuery(
      text: 'x',
      types: const {SearchEntityType.event, SearchEntityType.memory},
      conditions: [
        DateRangeCondition(from: d('2026-01-01')),
        const PersonCondition('p1'),
        const AgeRangeCondition(min: 1, max: 9),
        const TimeStateCondition(TimeState.past),
        const RecurringCondition(),
        const TagCondition('t'),
        const PriorityCondition(EventPriority.low),
      ],
      matchAll: false,
    );
    final back = SearchQuery.fromJson(q.toJson());
    expect(back.text, '');
    expect(back.toJson(), q.toJson());
  });
}
