import '../../../core/time_engine/time_engine.dart';
import 'person.dart';
import 'relationship.dart';

/// Multi-criteria people filter. All set criteria must match (AND);
/// within [categoryIds] any selected category matches (OR).
class PeopleFilter {
  const PeopleFilter({
    this.query = '',
    this.categoryIds = const {},
    this.minAge,
    this.maxAge,
    this.birthMonth,
    this.birthDay,
    this.birthYear,
    this.occupation,
    this.organization,
    this.relationType,
    this.hasBirthDate,
    this.birthdayWithinDays,
  });

  factory PeopleFilter.fromJson(Map<String, dynamic> j) => PeopleFilter(
        query: j['query'] as String? ?? '',
        categoryIds: {...(j['categoryIds'] as List<dynamic>? ?? const []).cast<String>()},
        minAge: j['minAge'] as int?,
        maxAge: j['maxAge'] as int?,
        birthMonth: j['birthMonth'] as int?,
        birthDay: j['birthDay'] as int?,
        birthYear: j['birthYear'] as int?,
        occupation: j['occupation'] as String?,
        organization: j['organization'] as String?,
        relationType: RelationshipType.values.asNameMap()[j['relationType']],
        hasBirthDate: j['hasBirthDate'] as bool?,
        birthdayWithinDays: j['birthdayWithinDays'] as int?,
      );

  static const schemaVersion = 1;
  static const empty = PeopleFilter();

  final String query;
  final Set<String> categoryIds;
  final int? minAge;
  final int? maxAge;
  final int? birthMonth;
  final int? birthDay;
  final int? birthYear;
  final String? occupation;
  final String? organization;
  final RelationshipType? relationType;
  final bool? hasBirthDate;
  final int? birthdayWithinDays;

  /// Number of active criteria other than the text query.
  int get activeCount => [
        categoryIds.isNotEmpty,
        minAge != null || maxAge != null,
        birthMonth != null,
        birthDay != null,
        birthYear != null,
        _has(occupation),
        _has(organization),
        relationType != null,
        hasBirthDate != null,
        birthdayWithinDays != null,
      ].where((b) => b).length;

  bool get isEmpty => activeCount == 0 && query.trim().isEmpty;

  static bool _has(String? s) => s != null && s.trim().isNotEmpty;
  static bool _contains(String? haystack, String needle) =>
      haystack != null && haystack.toLowerCase().contains(needle.trim().toLowerCase());

  /// [relationTypes]: relationship types where the person is the subject.
  bool matches(
    Person p, {
    required LocalDate today,
    required TimeEngine engine,
    Set<RelationshipType> relationTypes = const {},
  }) {
    final q = query.trim();
    if (q.isNotEmpty &&
        !(_contains(p.fullName, q) ||
            _contains(p.displayName, q) ||
            _contains(p.occupation, q) ||
            _contains(p.organization, q) ||
            _contains(p.notes, q))) {
      return false;
    }
    if (categoryIds.isNotEmpty && !p.categoryIds.any(categoryIds.contains)) return false;
    if (_has(occupation) && !_contains(p.occupation, occupation!)) return false;
    if (_has(organization) && !_contains(p.organization, organization!)) return false;
    if (relationType != null && !relationTypes.contains(relationType)) return false;
    if (hasBirthDate != null && (p.birthDate != null) != hasBirthDate) return false;

    final birth = p.birthDate;
    if (birthMonth != null && birth?.month != birthMonth) return false;
    if (birthDay != null && birth?.day != birthDay) return false;
    if (birthYear != null && (p.birthDateWithYear?.year != birthYear)) return false;

    if (minAge != null || maxAge != null) {
      final withYear = p.birthDateWithYear;
      final age = withYear == null ? null : engine.ageOn(withYear, today)?.years;
      if (age == null) return false;
      if (minAge != null && age < minAge!) return false;
      if (maxAge != null && age > maxAge!) return false;
    }
    if (birthdayWithinDays != null) {
      if (birth == null) return false;
      if (today.daysUntil(engine.nextBirthday(birth, today)) > birthdayWithinDays!) return false;
    }
    return true;
  }

  PeopleFilter copyWith({
    String? query,
    Set<String>? categoryIds,
    int? Function()? minAge,
    int? Function()? maxAge,
    int? Function()? birthMonth,
    int? Function()? birthDay,
    int? Function()? birthYear,
    String? Function()? occupation,
    String? Function()? organization,
    RelationshipType? Function()? relationType,
    bool? Function()? hasBirthDate,
    int? Function()? birthdayWithinDays,
  }) =>
      PeopleFilter(
        query: query ?? this.query,
        categoryIds: categoryIds ?? this.categoryIds,
        minAge: minAge != null ? minAge() : this.minAge,
        maxAge: maxAge != null ? maxAge() : this.maxAge,
        birthMonth: birthMonth != null ? birthMonth() : this.birthMonth,
        birthDay: birthDay != null ? birthDay() : this.birthDay,
        birthYear: birthYear != null ? birthYear() : this.birthYear,
        occupation: occupation != null ? occupation() : this.occupation,
        organization: organization != null ? organization() : this.organization,
        relationType: relationType != null ? relationType() : this.relationType,
        hasBirthDate: hasBirthDate != null ? hasBirthDate() : this.hasBirthDate,
        birthdayWithinDays: birthdayWithinDays != null ? birthdayWithinDays() : this.birthdayWithinDays,
      );

  /// Criteria only (the free-text query is not saved).
  Map<String, dynamic> toJson() => {
        'v': schemaVersion,
        if (categoryIds.isNotEmpty) 'categoryIds': categoryIds.toList(),
        'minAge': ?minAge,
        'maxAge': ?maxAge,
        'birthMonth': ?birthMonth,
        'birthDay': ?birthDay,
        'birthYear': ?birthYear,
        if (_has(occupation)) 'occupation': occupation,
        if (_has(organization)) 'organization': organization,
        'relationType': ?relationType?.name,
        'hasBirthDate': ?hasBirthDate,
        'birthdayWithinDays': ?birthdayWithinDays,
      };
}

class SavedPeopleFilter {
  const SavedPeopleFilter({required this.id, required this.name, required this.filter});
  final String id;
  final String name;
  final PeopleFilter filter;
}
