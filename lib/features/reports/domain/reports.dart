import '../../../core/time_engine/time_engine.dart';
import '../../agenda/agenda.dart';
import '../../commitments/domain/commitment.dart';
import '../../events/domain/event.dart';
import '../../memories/domain/memory.dart';
import '../../milestones/domain/milestone.dart';
import '../../people/domain/person.dart';

/// Age buckets for the distribution chart (inclusive lower bound).
const ageBuckets = [0, 18, 30, 45, 60];

class ReportData {
  const ReportData({
    required this.peopleCount,
    required this.peopleByCategory,
    required this.uncategorized,
    required this.ageBucketCounts,
    required this.unknownAge,
    required this.birthdaysByMonth,
    required this.eventsByType,
    required this.upcoming,
    required this.commitmentsByStatus,
    required this.memoriesCount,
    required this.milestonesCount,
  });

  final int peopleCount;

  /// categoryId → number of people (a person can be in several).
  final Map<String, int> peopleByCategory;
  final int uncategorized;

  /// Same length as [ageBuckets].
  final List<int> ageBucketCounts;
  final int unknownAge;

  /// 12 entries, January first.
  final List<int> birthdaysByMonth;

  /// eventTypeId → number of events (series count once).
  final Map<String, int> eventsByType;

  /// days (7/30/90) → number of agenda items (birthdays, event occurrences, commitments) from today.
  final Map<int, int> upcoming;
  final Map<CommitmentStatus, int> commitmentsByStatus;
  final int memoriesCount;
  final int milestonesCount;
}

class ReportService {
  const ReportService(this._agenda, this._time, this._rules);
  final AgendaService _agenda;
  final TimeEngine _time;
  final CommitmentRules _rules;

  ReportData build({
    required LocalDate today,
    required List<Person> people,
    required List<DateiEvent> events,
    required List<Commitment> commitments,
    required List<Memory> memories,
    required List<Milestone> milestones,
  }) {
    final byCategory = <String, int>{};
    var uncategorized = 0;
    final buckets = List.filled(ageBuckets.length, 0);
    var unknownAge = 0;
    final months = List.filled(12, 0);
    for (final p in people) {
      if (p.categoryIds.isEmpty) uncategorized++;
      for (final c in p.categoryIds) {
        byCategory[c] = (byCategory[c] ?? 0) + 1;
      }
      final withYear = p.birthDateWithYear;
      final age = withYear == null ? null : _time.ageOn(withYear, today)?.years;
      if (age == null) {
        unknownAge++;
      } else {
        var i = ageBuckets.length - 1;
        while (i > 0 && age < ageBuckets[i]) {
          i--;
        }
        buckets[i]++;
      }
      if (p.birthDate != null) months[p.birthDate!.month - 1]++;
    }

    final byType = <String, int>{};
    for (final e in events) {
      byType[e.typeId] = (byType[e.typeId] ?? 0) + 1;
    }

    final upcoming = {
      for (final days in const [7, 30, 90])
        days: _agenda
            .itemsInRange(people: people, events: events, commitments: commitments, from: today, to: today.addDays(days))
            .length,
    };

    final byStatus = {for (final s in CommitmentStatus.values) s: 0};
    for (final c in commitments) {
      final s = _rules.statusOf(c, today);
      byStatus[s] = byStatus[s]! + 1;
    }

    return ReportData(
      peopleCount: people.length,
      peopleByCategory: byCategory,
      uncategorized: uncategorized,
      ageBucketCounts: buckets,
      unknownAge: unknownAge,
      birthdaysByMonth: months,
      eventsByType: byType,
      upcoming: upcoming,
      commitmentsByStatus: byStatus,
      memoriesCount: memories.length,
      milestonesCount: milestones.length,
    );
  }
}
