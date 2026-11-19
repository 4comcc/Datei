import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/time_engine/time_engine.dart';
import '../events/presentation/events_providers.dart';
import '../events/domain/event.dart';
import '../people/presentation/people_providers.dart';
import '../people/domain/person.dart';

final timeEngineProvider = Provider<TimeEngine>((ref) => const TimeEngine());

/// "Today" as seen by the app. Overridable in tests.
final todayProvider = Provider<LocalDate>((ref) => LocalDate.today());

enum AgendaKind { birthday, event }

/// One dated occurrence shown on Home / Calendar / Events.
class AgendaItem {
  const AgendaItem.birthday({required this.date, required Person this.person, required int this.turningAge})
      : kind = AgendaKind.birthday,
        event = null;

  const AgendaItem.event({required this.date, required DateiEvent this.event})
      : kind = AgendaKind.event,
        person = null,
        turningAge = null;

  final AgendaKind kind;
  final LocalDate date;
  final Person? person;
  final DateiEvent? event;
  final int? turningAge;

  String get sortTime => event?.time ?? '';
}

/// Builds agenda occurrences from people (birthdays) and events.
/// Single source for every screen that lists dated items.
class AgendaService {
  const AgendaService(this._engine);
  final TimeEngine _engine;

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
        for (final d in _engine.yearlyOccurrences(birth, from, to, includeOrigin: false)) {
          items.add(AgendaItem.birthday(date: d, person: p, turningAge: d.year - birth.year));
        }
      }
    }
    if (includeEvents) {
      for (final e in events) {
        if (e.repeatsYearly) {
          for (final d in _engine.yearlyOccurrences(e.date, from, to)) {
            items.add(AgendaItem.event(date: d, event: e));
          }
        } else if (!e.date.isBefore(from) && !e.date.isAfter(to)) {
          items.add(AgendaItem.event(date: e.date, event: e));
        }
      }
    }
    items.sort((a, b) {
      final c = a.date.compareTo(b.date);
      return c != 0 ? c : a.sortTime.compareTo(b.sortTime);
    });
    return items;
  }
}

final agendaServiceProvider = Provider<AgendaService>((ref) => AgendaService(ref.watch(timeEngineProvider)));

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

/// Items in a given inclusive range, keyed by (from, to) ISO strings.
final agendaRangeProvider = Provider.family<List<AgendaItem>, (LocalDate, LocalDate)>((ref, range) {
  return ref.watch(agendaServiceProvider).itemsInRange(
        people: ref.watch(peopleProvider),
        events: ref.watch(eventsProvider),
        from: range.$1,
        to: range.$2,
      );
});
