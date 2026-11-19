import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/recurrence_engine/recurrence.dart';
import '../../core/time_engine/time_engine.dart';
import '../events/domain/event.dart';
import '../events/presentation/events_providers.dart';
import '../people/domain/person.dart';
import '../people/presentation/people_providers.dart';

final timeEngineProvider = Provider<TimeEngine>((ref) => const TimeEngine());
final recurrenceEngineProvider = Provider<RecurrenceEngine>((ref) => RecurrenceEngine(ref.watch(timeEngineProvider)));

/// "Today" as seen by the app. Overridable in tests.
final todayProvider = Provider<LocalDate>((ref) => LocalDate.today());

enum AgendaKind { birthday, event }

/// One dated occurrence shown on Home / Calendar / Events.
class AgendaItem {
  const AgendaItem.birthday({required this.date, required Person this.person, required this.turningAge})
      : kind = AgendaKind.birthday,
        event = null,
        occurrenceDate = null,
        endDate = null,
        title = null,
        time = null;

  const AgendaItem.event({
    required this.date,
    required DateiEvent this.event,
    required LocalDate this.occurrenceDate,
    required String this.title,
    this.endDate,
    this.time,
  })  : kind = AgendaKind.event,
        person = null,
        turningAge = null;

  final AgendaKind kind;

  /// Day the item is shown on (start day for multi-day events).
  final LocalDate date;

  /// Last day for multi-day events.
  final LocalDate? endDate;
  final Person? person;
  final DateiEvent? event;

  /// The occurrence's original date in its series (identifies it for edits).
  final LocalDate? occurrenceDate;

  /// Effective title/time (after a per-occurrence override).
  final String? title;
  final String? time;

  /// Age reached on this birthday; null when the birth year is unknown.
  final int? turningAge;

  String get sortTime => time ?? '';

  bool coversDay(LocalDate day) => !day.isBefore(date) && !day.isAfter(endDate ?? date);
}

/// Builds agenda occurrences from people (birthdays) and events.
/// Single source for every screen that lists dated items.
class AgendaService {
  const AgendaService(this._time, this._recurrence);
  final TimeEngine _time;
  final RecurrenceEngine _recurrence;

  /// All event occurrences (after exceptions) whose span intersects [from]..[to].
  Iterable<AgendaItem> eventOccurrences(DateiEvent e, LocalDate from, LocalDate to) sync* {
    final span = e.spanDays;
    final rule = e.recurrence;
    if (rule == null) {
      final end = e.date.addDays(span);
      if (!end.isBefore(from) && !e.date.isAfter(to)) {
        yield AgendaItem.event(
          date: e.date,
          endDate: span > 0 ? end : null,
          event: e,
          occurrenceDate: e.date,
          title: e.title,
          time: e.time,
        );
      }
      return;
    }
    final byDate = {for (final x in e.exceptions) x.originalDate: x};
    // Overrides may move an occurrence by a few weeks; widen the scan so moved items are found.
    const moveMargin = 62;
    for (final original in _recurrence.occurrences(
      e.date,
      rule,
      from: from.addDays(-span - moveMargin),
      to: to.addDays(moveMargin),
    )) {
      final ex = byDate[original];
      if (ex != null && ex.isCancelled) continue;
      final o = ex?.override;
      final start = o?.date ?? original;
      final end = start.addDays(span);
      if (end.isBefore(from) || start.isAfter(to)) continue;
      yield AgendaItem.event(
        date: start,
        endDate: span > 0 ? end : null,
        event: e,
        occurrenceDate: original,
        title: (o?.title?.trim().isNotEmpty ?? false) ? o!.title! : e.title,
        time: (o?.clearTime ?? false) ? null : (o?.time ?? e.time),
      );
    }
  }

  /// Next occurrence on/after [from] (for "upcoming" lists).
  AgendaItem? nextOccurrence(DateiEvent e, LocalDate from) {
    for (final window in const [62, 400, 1900]) {
      for (final item in eventOccurrences(e, from, from.addDays(window))) {
        if (!item.date.isBefore(from) || item.coversDay(from)) return item;
      }
    }
    return null;
  }

  List<AgendaItem> itemsInRange({
    required List<Person> people,
    required List<DateiEvent> events,
    required LocalDate from,
    required LocalDate to,
    bool includeBirthdays = true,
    bool includeEvents = true,
  }) {
    final items = <AgendaItem>[];
    if (includeBirthdays) {
      for (final p in people) {
        final birth = p.birthDate;
        if (birth == null) continue;
        for (final d in _time.yearlyOccurrences(birth, from, to, includeOrigin: false)) {
          items.add(AgendaItem.birthday(date: d, person: p, turningAge: p.birthYearKnown ? d.year - birth.year : null));
        }
      }
    }
    if (includeEvents) {
      for (final e in events) {
        items.addAll(eventOccurrences(e, from, to));
      }
    }
    items.sort((a, b) {
      final c = a.date.compareTo(b.date);
      return c != 0 ? c : a.sortTime.compareTo(b.sortTime);
    });
    return items;
  }
}

final agendaServiceProvider = Provider<AgendaService>(
  (ref) => AgendaService(ref.watch(timeEngineProvider), ref.watch(recurrenceEngineProvider)),
);

/// Items from today through the next [days] days.
final upcomingAgendaProvider = Provider.family<List<AgendaItem>, int>((ref, days) {
  final today = ref.watch(todayProvider);
  return ref.watch(agendaServiceProvider).itemsInRange(
        people: ref.watch(peopleProvider),
        events: ref.watch(eventsProvider),
        from: today,
        to: today.addDays(days),
      );
});

/// Items in a given inclusive range.
final agendaRangeProvider = Provider.family<List<AgendaItem>, (LocalDate, LocalDate)>((ref, range) {
  return ref.watch(agendaServiceProvider).itemsInRange(
        people: ref.watch(peopleProvider),
        events: ref.watch(eventsProvider),
        from: range.$1,
        to: range.$2,
      );
});
