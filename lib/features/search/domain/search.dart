import '../../../core/time_engine/time_engine.dart';
import '../../../core/utils/text_normalize.dart';
import '../../agenda/agenda.dart';
import '../../commitments/domain/commitment.dart';
import '../../events/domain/event.dart';
import '../../memories/domain/memory.dart';
import '../../milestones/domain/milestone.dart';
import '../../people/domain/person.dart';
import '../../projects/domain/project.dart';

enum SearchEntityType { person, event, commitment, memory, milestone, project }

enum TimeState { upcoming, past, overdue }

/// One filter condition. Conditions that do not apply to an item count as not met.
sealed class SearchCondition {
  const SearchCondition();

  Map<String, dynamic> toJson();

  static SearchCondition? fromJson(Map<String, dynamic> j) => switch (j['k']) {
        'date' => DateRangeCondition(
            from: j['from'] == null ? null : LocalDate.parse(j['from'] as String),
            to: j['to'] == null ? null : LocalDate.parse(j['to'] as String),
          ),
        'person' => PersonCondition(j['id'] as String),
        'eventType' => EventTypeCondition(j['id'] as String),
        'category' => CategoryCondition(j['id'] as String),
        'age' => AgeRangeCondition(min: j['min'] as int?, max: j['max'] as int?),
        'priority' => PriorityCondition(EventPriority.values.asNameMap()[j['v']] ?? EventPriority.normal),
        'time' => TimeStateCondition(TimeState.values.asNameMap()[j['v']] ?? TimeState.upcoming),
        'recurring' => const RecurringCondition(),
        'tag' => TagCondition(j['v'] as String),
        _ => null,
      };
}

class DateRangeCondition extends SearchCondition {
  const DateRangeCondition({this.from, this.to});
  final LocalDate? from;
  final LocalDate? to;
  @override
  Map<String, dynamic> toJson() => {'k': 'date', 'from': ?from?.toIso(), 'to': ?to?.toIso()};
}

class PersonCondition extends SearchCondition {
  const PersonCondition(this.personId);
  final String personId;
  @override
  Map<String, dynamic> toJson() => {'k': 'person', 'id': personId};
}

class EventTypeCondition extends SearchCondition {
  const EventTypeCondition(this.typeId);
  final String typeId;
  @override
  Map<String, dynamic> toJson() => {'k': 'eventType', 'id': typeId};
}

class CategoryCondition extends SearchCondition {
  const CategoryCondition(this.categoryId);
  final String categoryId;
  @override
  Map<String, dynamic> toJson() => {'k': 'category', 'id': categoryId};
}

class AgeRangeCondition extends SearchCondition {
  const AgeRangeCondition({this.min, this.max});
  final int? min;
  final int? max;
  @override
  Map<String, dynamic> toJson() => {'k': 'age', 'min': ?min, 'max': ?max};
}

class PriorityCondition extends SearchCondition {
  const PriorityCondition(this.priority);
  final EventPriority priority;
  @override
  Map<String, dynamic> toJson() => {'k': 'priority', 'v': priority.name};
}

class TimeStateCondition extends SearchCondition {
  const TimeStateCondition(this.state);
  final TimeState state;
  @override
  Map<String, dynamic> toJson() => {'k': 'time', 'v': state.name};
}

class RecurringCondition extends SearchCondition {
  const RecurringCondition();
  @override
  Map<String, dynamic> toJson() => {'k': 'recurring'};
}

class TagCondition extends SearchCondition {
  const TagCondition(this.tag);
  final String tag;
  @override
  Map<String, dynamic> toJson() => {'k': 'tag', 'v': tag};
}

class SearchQuery {
  const SearchQuery({this.text = '', this.types = const {}, this.conditions = const [], this.matchAll = true});

  factory SearchQuery.fromJson(Map<String, dynamic> j) => SearchQuery(
        types: {
          for (final t in (j['types'] as List<dynamic>? ?? const []).cast<String>()) ?SearchEntityType.values.asNameMap()[t],
        },
        conditions: [
          for (final c in (j['conditions'] as List<dynamic>? ?? const []).cast<Map<String, dynamic>>())
            ?SearchCondition.fromJson(c),
        ],
        matchAll: j['matchAll'] as bool? ?? true,
      );

  final String text;

  /// Empty = all types.
  final Set<SearchEntityType> types;
  final List<SearchCondition> conditions;

  /// true: every condition must hold (AND); false: at least one (OR).
  final bool matchAll;

  bool get isEmpty => text.trim().isEmpty && conditions.isEmpty && types.isEmpty;

  SearchQuery copyWith({String? text, Set<SearchEntityType>? types, List<SearchCondition>? conditions, bool? matchAll}) =>
      SearchQuery(
        text: text ?? this.text,
        types: types ?? this.types,
        conditions: conditions ?? this.conditions,
        matchAll: matchAll ?? this.matchAll,
      );

  /// Saved without the free text (v1).
  Map<String, dynamic> toJson() => {
        'v': 1,
        'types': [for (final t in types) t.name],
        'conditions': [for (final c in conditions) c.toJson()],
        'matchAll': matchAll,
      };
}

class SavedSearch {
  const SavedSearch({required this.id, required this.name, required this.query});
  final String id;
  final String name;
  final SearchQuery query;
}

class SearchResult {
  const SearchResult({required this.type, required this.id, required this.title, required this.route, this.date, this.subtitle, this.score = 0});
  final SearchEntityType type;
  final String id;
  final String title;
  final String? subtitle;
  final LocalDate? date;
  final String route;
  final int score;
}

/// Everything the engine can search.
class SearchData {
  const SearchData({
    this.people = const [],
    this.events = const [],
    this.commitments = const [],
    this.memories = const [],
    this.milestones = const [],
    this.projects = const [],
  });
  final List<Person> people;
  final List<DateiEvent> events;
  final List<Commitment> commitments;
  final List<Memory> memories;
  final List<Milestone> milestones;
  final List<Project> projects;
}

/// Unified, in-memory search (personal data sizes; ADR-060). Pure.
class SearchEngine {
  const SearchEngine(this._agenda, this._time, this._rules);
  final AgendaService _agenda;
  final TimeEngine _time;
  final CommitmentRules _rules;

  List<SearchResult> search(SearchQuery q, SearchData data, LocalDate today) {
    final needle = normalizeForSearch(q.text);
    final types = q.types.isEmpty ? SearchEntityType.values.toSet() : q.types;
    final out = <SearchResult>[];

    int score(String title, List<String?> other) {
      if (needle.isEmpty) return 1;
      final t = normalizeForSearch(title);
      if (t.startsWith(needle)) return 3;
      if (t.contains(needle)) return 2;
      for (final o in other) {
        if (o != null && normalizeForSearch(o).contains(needle)) return 1;
      }
      return 0;
    }

    bool conditionsHold(bool Function(SearchCondition) check) {
      if (q.conditions.isEmpty) return true;
      return q.matchAll ? q.conditions.every(check) : q.conditions.any(check);
    }

    bool inRange(LocalDate d, DateRangeCondition c) =>
        (c.from == null || !d.isBefore(c.from!)) && (c.to == null || !d.isAfter(c.to!));

    void add(SearchResult r) {
      if (r.score > 0) out.add(r);
    }

    if (types.contains(SearchEntityType.person)) {
      for (final p in data.people) {
        final s = score(p.fullName, [p.displayName, p.occupation, p.organization, p.notes, p.email, p.phone, p.address]);
        if (s == 0) continue;
        final birth = p.birthDate;
        final age = p.birthDateWithYear == null ? null : _time.ageOn(p.birthDateWithYear!, today)?.years;
        final ok = conditionsHold((c) => switch (c) {
              DateRangeCondition() => birth != null &&
                  _time.yearlyOccurrences(birth, c.from ?? today, c.to ?? today.addDays(366), includeOrigin: false).isNotEmpty,
              PersonCondition() => p.id == c.personId,
              CategoryCondition() => p.categoryIds.contains(c.categoryId),
              AgeRangeCondition() => age != null && (c.min == null || age >= c.min!) && (c.max == null || age <= c.max!),
              _ => false,
            });
        if (ok) {
          add(SearchResult(type: SearchEntityType.person, id: p.id, title: p.shownName, subtitle: p.occupation, date: birth, route: '/people/${p.id}', score: s));
        }
      }
    }

    if (types.contains(SearchEntityType.event)) {
      for (final e in data.events) {
        final s = score(e.title, [e.notes, e.location]);
        if (s == 0) continue;
        final next = _agenda.nextOccurrence(e, today);
        final isPast = next == null;
        final ok = conditionsHold((c) => switch (c) {
              DateRangeCondition() =>
                _agenda.eventOccurrences(e, c.from ?? LocalDate(1800, 1, 1), c.to ?? today.addDays(3660)).isNotEmpty,
              PersonCondition() => e.personIds.contains(c.personId),
              EventTypeCondition() => e.typeId == c.typeId,
              PriorityCondition() => e.priority == c.priority,
              TimeStateCondition() => switch (c.state) {
                  TimeState.upcoming => !isPast,
                  TimeState.past => isPast,
                  TimeState.overdue => isPast && e.status == EventStatus.planned && !e.isRecurring,
                },
              RecurringCondition() => e.isRecurring,
              _ => false,
            });
        if (ok) {
          add(SearchResult(
            type: SearchEntityType.event,
            id: e.id,
            title: e.title,
            subtitle: e.location,
            date: next?.date ?? e.date,
            route: e.isRecurring && next != null ? '/events/${e.id}/edit?occurrence=${next.occurrenceDate}' : '/events/${e.id}/edit',
            score: s,
          ));
        }
      }
    }

    if (types.contains(SearchEntityType.commitment)) {
      for (final cm in data.commitments) {
        final s = score(cm.name, [cm.providerName, cm.referenceNumber, cm.notes, cm.serviceUrl]);
        if (s == 0) continue;
        final status = _rules.statusOf(cm, today);
        final ok = conditionsHold((c) => switch (c) {
              DateRangeCondition() => inRange(cm.dueDate, c),
              TimeStateCondition() => switch (c.state) {
                  TimeState.upcoming => cm.lifecycle == CommitmentLifecycle.active && !cm.dueDate.isBefore(today),
                  TimeState.past => cm.lifecycle != CommitmentLifecycle.active,
                  TimeState.overdue => status == CommitmentStatus.overdue,
                },
              RecurringCondition() => cm.renewalMonths != null,
              _ => false,
            });
        if (ok) {
          add(SearchResult(type: SearchEntityType.commitment, id: cm.id, title: cm.name, subtitle: cm.providerName, date: cm.dueDate, route: '/commitments/${cm.id}', score: s));
        }
      }
    }

    if (types.contains(SearchEntityType.memory)) {
      for (final m in data.memories) {
        final s = score(m.title, [m.body, m.category, ...m.tags]);
        if (s == 0) continue;
        final ok = conditionsHold((c) => switch (c) {
              DateRangeCondition() => inRange(m.date, c),
              PersonCondition() => m.personIds.contains(c.personId),
              TagCondition() => m.tags.any((t) => normalizeForSearch(t) == normalizeForSearch(c.tag)),
              TimeStateCondition() => c.state == TimeState.past ? !m.date.isAfter(today) : c.state == TimeState.upcoming && m.date.isAfter(today),
              _ => false,
            });
        if (ok) {
          add(SearchResult(type: SearchEntityType.memory, id: m.id, title: m.title, subtitle: m.body, date: m.date, route: '/memories/${m.id}', score: s));
        }
      }
    }

    if (types.contains(SearchEntityType.milestone)) {
      for (final m in data.milestones) {
        final s = score(m.title, [m.description]);
        if (s == 0) continue;
        final ok = conditionsHold((c) => switch (c) {
              DateRangeCondition() => inRange(m.date, c),
              PersonCondition() => m.personId == c.personId,
              TimeStateCondition() => c.state == TimeState.past ? !m.date.isAfter(today) : c.state == TimeState.upcoming && m.date.isAfter(today),
              _ => false,
            });
        if (ok) {
          add(SearchResult(type: SearchEntityType.milestone, id: m.id, title: m.title, subtitle: m.description, date: m.date, route: '/milestones/${m.id}/edit', score: s));
        }
      }
    }

    if (types.contains(SearchEntityType.project)) {
      for (final p in data.projects) {
        final s = score(p.name, [p.description, p.notes]);
        if (s == 0) continue;
        final ok = conditionsHold((c) => switch (c) {
              DateRangeCondition() => (p.startDate != null && inRange(p.startDate!, c)) || (p.dueDate != null && inRange(p.dueDate!, c)),
              PersonCondition() => p.personIds.contains(c.personId),
              PriorityCondition() => p.priority == c.priority,
              TimeStateCondition() => switch (c.state) {
                  TimeState.upcoming => p.isOpen && (p.dueDate == null || !p.dueDate!.isBefore(today)),
                  TimeState.past => !p.isOpen,
                  TimeState.overdue => p.isOverdue(today),
                },
              _ => false,
            });
        if (ok) {
          add(SearchResult(type: SearchEntityType.project, id: p.id, title: p.name, subtitle: p.description, date: p.dueDate ?? p.startDate, route: '/projects/${p.id}', score: s));
        }
      }
    }

    out.sort((a, b) {
      final c = b.score.compareTo(a.score);
      if (c != 0) return c;
      final ad = a.date, bd = b.date;
      if (ad == null || bd == null) return ad == null ? (bd == null ? a.title.compareTo(b.title) : 1) : -1;
      return today.daysUntil(ad).abs().compareTo(today.daysUntil(bd).abs()); // closest to today first
    });
    return out;
  }
}
