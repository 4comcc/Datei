import '../../../core/recurrence_engine/recurrence.dart';
import '../../../core/time_engine/local_date.dart';
import '../../agenda/agenda.dart';
import '../../events/domain/event.dart';
import '../../memories/domain/memory.dart';
import '../../milestones/domain/milestone.dart';
import '../../people/domain/person.dart';
import '../../projects/domain/project.dart';

enum TimelineKind { birth, birthday, event, memory, milestone, projectStart, projectDue }

/// Filter groups shown to the user.
enum TimelineGroup { events, birthdays, memories, milestones, projects }

enum TimelinePeriod { all, pastYear, thisYear, upcoming }

class TimelineEntry {
  const TimelineEntry({
    required this.date,
    required this.kind,
    required this.title,
    required this.route,
    this.endDate,
    this.subtitle,
    this.eventTypeId,
    this.milestoneKind,
    this.photoCount = 0,
    this.turningAge,
  });

  final LocalDate date;
  final LocalDate? endDate;
  final TimelineKind kind;
  final String title;
  final String? subtitle;
  final String route;
  final String? eventTypeId;
  final MilestoneKind? milestoneKind;
  final int photoCount;
  final int? turningAge;

  TimelineGroup get group => switch (kind) {
        TimelineKind.birth || TimelineKind.birthday => TimelineGroup.birthdays,
        TimelineKind.event => TimelineGroup.events,
        TimelineKind.memory => TimelineGroup.memories,
        TimelineKind.milestone => TimelineGroup.milestones,
        TimelineKind.projectStart || TimelineKind.projectDue => TimelineGroup.projects,
      };
}

/// Builds the life timeline (all items, or one person's). Pure.
class TimelineService {
  const TimelineService(this._agenda);
  final AgendaService _agenda;

  /// Recurring items (repeating events, birthdays) are expanded only within this
  /// many days around today so "All" stays readable; one-off items are never cut.
  static const recurringWindowDays = 365;

  (LocalDate, LocalDate) window(TimelinePeriod period, LocalDate today) => switch (period) {
        TimelinePeriod.all => (LocalDate(1800, 1, 1), today.addDays(recurringWindowDays)),
        TimelinePeriod.pastYear => (today.addDays(-365), today),
        TimelinePeriod.thisYear => (LocalDate(today.year, 1, 1), LocalDate(today.year, 12, 31)),
        TimelinePeriod.upcoming => (today, today.addDays(recurringWindowDays)),
      };

  List<TimelineEntry> build({
    required LocalDate today,
    required TimelinePeriod period,
    required List<Person> people,
    required List<DateiEvent> events,
    required List<Memory> memories,
    required List<Milestone> milestones,
    required List<Project> projects,
    Set<TimelineGroup> groups = const {...TimelineGroup.values},
    String? personId,
  }) {
    final (from, to) = window(period, today);
    bool inRange(LocalDate d) => !d.isBefore(from) && !d.isAfter(to);
    final recurringFrom = from.isBefore(today.addDays(-recurringWindowDays)) ? today.addDays(-recurringWindowDays) : from;
    final out = <TimelineEntry>[];
    final scopedPeople = personId == null ? people : people.where((p) => p.id == personId).toList();

    if (groups.contains(TimelineGroup.birthdays)) {
      for (final p in scopedPeople) {
        final birth = p.birthDateWithYear;
        if (birth != null && inRange(birth)) {
          out.add(TimelineEntry(date: birth, kind: TimelineKind.birth, title: p.shownName, route: '/people/${p.id}'));
        }
      }
      for (final item in _agenda.itemsInRange(people: scopedPeople, events: const [], from: recurringFrom, to: to)) {
        out.add(TimelineEntry(
          date: item.date,
          kind: TimelineKind.birthday,
          title: item.person!.shownName,
          turningAge: item.turningAge,
          route: '/people/${item.person!.id}',
        ));
      }
    }

    if (groups.contains(TimelineGroup.events)) {
      for (final e in events) {
        if (personId != null && !e.personIds.contains(personId)) continue;
        if (e.status == EventStatus.cancelled) continue;
        final Iterable<AgendaItem> occurrences;
        if (!e.isRecurring) {
          occurrences = _agenda.eventOccurrences(e, from, to);
        } else if (e.recurrence!.frequency == RecurrenceFrequency.yearly) {
          // Anniversaries are life events: show each year within the window.
          occurrences = _agenda.eventOccurrences(e, recurringFrom, to);
        } else {
          // Frequent series (daily/weekly/monthly) are schedules, not milestones:
          // show where the series started and its next occurrence only.
          occurrences = {
            for (final o in [
              ..._agenda.eventOccurrences(e, e.date, e.date),
              ?_agenda.nextOccurrence(e, today),
            ])
              if (!o.date.isBefore(from) && !o.date.isAfter(to)) o.occurrenceDate: o,
          }.values;
        }
        for (final o in occurrences) {
          out.add(TimelineEntry(
            date: o.date,
            endDate: o.endDate,
            kind: TimelineKind.event,
            title: o.title!,
            subtitle: e.location,
            eventTypeId: e.typeId,
            route: e.isRecurring ? '/events/${e.id}/edit?occurrence=${o.occurrenceDate}' : '/events/${e.id}/edit',
          ));
        }
      }
    }

    if (groups.contains(TimelineGroup.memories)) {
      for (final m in memories) {
        if (personId != null && !m.personIds.contains(personId)) continue;
        if (!inRange(m.date)) continue;
        out.add(TimelineEntry(
          date: m.date,
          kind: TimelineKind.memory,
          title: m.title,
          subtitle: m.body,
          photoCount: m.photos.length,
          route: '/memories/${m.id}',
        ));
      }
    }

    if (groups.contains(TimelineGroup.milestones)) {
      for (final m in milestones) {
        if (personId != null && m.personId != personId) continue;
        if (!inRange(m.date)) continue;
        out.add(TimelineEntry(
          date: m.date,
          kind: TimelineKind.milestone,
          title: m.title,
          subtitle: m.description,
          milestoneKind: m.kind,
          route: '/milestones/${m.id}/edit',
        ));
      }
    }

    if (groups.contains(TimelineGroup.projects)) {
      for (final p in projects) {
        if (personId != null && !p.personIds.contains(personId)) continue;
        if (p.status == ProjectStatus.cancelled) continue;
        if (p.startDate != null && inRange(p.startDate!)) {
          out.add(TimelineEntry(date: p.startDate!, kind: TimelineKind.projectStart, title: p.name, route: '/projects/${p.id}'));
        }
        if (p.dueDate != null && inRange(p.dueDate!)) {
          out.add(TimelineEntry(date: p.dueDate!, kind: TimelineKind.projectDue, title: p.name, route: '/projects/${p.id}'));
        }
      }
    }

    // Newest first: the future at the top, the past below.
    out.sort((a, b) {
      final c = b.date.compareTo(a.date);
      return c != 0 ? c : a.kind.index.compareTo(b.kind.index);
    });
    return out;
  }
}
