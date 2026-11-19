import 'package:datei/core/time_engine/time_engine.dart';
import 'package:datei/features/people/domain/people_filter.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/people/domain/relationship.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = TimeEngine();
  final today = LocalDate.parse('2026-11-19');
  final created = DateTime(2026);
  Person p(String name, {String? birth, bool yearKnown = true, List<String> cats = const [], String? job, String? org}) =>
      Person(
        id: name,
        fullName: name,
        birthDate: birth == null ? null : LocalDate.parse(birth),
        birthYearKnown: yearKnown,
        categoryIds: cats,
        occupation: job,
        organization: org,
        createdAt: created,
      );

  final sara = p('Sara Ahmed', birth: '1996-11-24', cats: ['family'], job: 'Engineer', org: 'Datei Co');
  final omar = p('Omar', birth: '1988-03-02', cats: ['friends'], job: 'Teacher');
  final mona = p('Mona', birth: '2000-02-29', yearKnown: false, cats: ['friends', 'family']);
  final noDate = p('Zed');
  final all = [sara, omar, mona, noDate];

  List<String> run(PeopleFilter f, {Map<String, Set<RelationshipType>> rel = const {}}) => [
        for (final x in all)
          if (f.matches(x, today: today, engine: engine, relationTypes: rel[x.id] ?? const {})) x.fullName,
      ];

  test('empty filter matches everyone', () => expect(run(PeopleFilter.empty), hasLength(4)));

  test('text query searches name, occupation and workplace (case-insensitive)', () {
    expect(run(const PeopleFilter(query: 'sara')), ['Sara Ahmed']);
    expect(run(const PeopleFilter(query: 'teach')), ['Omar']);
    expect(run(const PeopleFilter(query: 'datei co')), ['Sara Ahmed']);
  });

  test('categories match any of the selected', () {
    expect(run(const PeopleFilter(categoryIds: {'family'})), ['Sara Ahmed', 'Mona']);
    expect(run(const PeopleFilter(categoryIds: {'family', 'friends'})), ['Sara Ahmed', 'Omar', 'Mona']);
  });

  test('age range excludes unknown ages and unknown birth years', () {
    expect(run(const PeopleFilter(minAge: 30)), ['Omar']);
    expect(run(const PeopleFilter(maxAge: 29)), ['Sara Ahmed']);
    expect(run(const PeopleFilter(minAge: 29, maxAge: 38)), ['Sara Ahmed', 'Omar']);
  });

  test('birth month, day and year', () {
    expect(run(const PeopleFilter(birthMonth: 2)), ['Mona']);
    expect(run(const PeopleFilter(birthDay: 24)), ['Sara Ahmed']);
    expect(run(const PeopleFilter(birthYear: 2000)), isEmpty, reason: 'placeholder year must not match');
    expect(run(const PeopleFilter(birthYear: 1988)), ['Omar']);
  });

  test('has birth date', () {
    expect(run(const PeopleFilter(hasBirthDate: false)), ['Zed']);
    expect(run(const PeopleFilter(hasBirthDate: true)), hasLength(3));
  });

  test('birthday within N days (works without the year)', () {
    expect(run(const PeopleFilter(birthdayWithinDays: 7)), ['Sara Ahmed']);
    // Mona (Feb 29, observed Feb 28 2027) is 101 days away; Omar (Mar 2) 103.
    expect(run(const PeopleFilter(birthdayWithinDays: 101)), ['Sara Ahmed', 'Mona']);
  });

  test('relationship type and combined criteria (AND)', () {
    final rel = {'Omar': {RelationshipType.colleague}};
    expect(run(const PeopleFilter(relationType: RelationshipType.colleague), rel: rel), ['Omar']);
    expect(run(const PeopleFilter(categoryIds: {'friends'}, occupation: 'teacher')), ['Omar']);
    expect(run(const PeopleFilter(categoryIds: {'family'}, minAge: 40)), isEmpty);
  });

  test('JSON roundtrip keeps criteria but not the free-text query', () {
    const f = PeopleFilter(
      query: 'x',
      categoryIds: {'family'},
      minAge: 18,
      maxAge: 40,
      birthMonth: 11,
      relationType: RelationshipType.friend,
      hasBirthDate: true,
      birthdayWithinDays: 30,
      occupation: 'eng',
    );
    final back = PeopleFilter.fromJson(f.toJson());
    expect(back.query, '');
    expect(back.toJson(), f.toJson());
    expect(back.activeCount, f.activeCount);
  });

  test('activeCount counts criteria groups', () {
    expect(const PeopleFilter(minAge: 1, maxAge: 5, birthMonth: 3).activeCount, 2);
  });

  group('TimeEngine.difference', () {
    test('months and days with month-end clamping', () {
      expect(engine.difference(LocalDate.parse('2026-11-19'), LocalDate.parse('2026-11-24')), const AgeBreakdown(0, 0, 5));
      expect(engine.difference(LocalDate.parse('2026-11-19'), LocalDate.parse('2027-02-28')), const AgeBreakdown(0, 3, 9));
      expect(engine.difference(LocalDate.parse('2026-01-31'), LocalDate.parse('2026-02-28')), const AgeBreakdown(0, 1, 0));
      expect(engine.difference(LocalDate.parse('2026-01-31'), LocalDate.parse('2026-03-31')), const AgeBreakdown(0, 2, 0));
      expect(engine.difference(LocalDate.parse('2026-02-01'), LocalDate.parse('2026-01-01')), isNull);
    });
  });
}
