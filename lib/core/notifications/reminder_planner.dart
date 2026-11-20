import '../../features/agenda/agenda.dart';
import '../../features/commitments/domain/commitment.dart';
import '../../features/events/domain/event.dart';
import '../../features/people/domain/person.dart';
import '../time_engine/time_engine.dart';

/// A notification to schedule at a local wall-clock time.
class PlannedNotification {
  const PlannedNotification({required this.id, required this.fireAt, required this.title, required this.body, required this.route});

  /// Stable id (same reminder → same id across re-plans).
  final int id;

  /// Local wall-clock time (no time zone; the scheduler applies the device zone).
  final DateTime fireAt;
  final String title;
  final String body;

  /// In-app route opened when the notification is tapped.
  final String route;

  @override
  String toString() => '$fireAt $title';
}

/// User preferences that affect planning.
class ReminderSettings {
  const ReminderSettings({this.enabled = false, this.defaultTime = '09:00', this.birthdayDaysBefore});
  final bool enabled;

  /// `HH:mm` used for all-day items (birthdays, commitments, all-day events).
  final String defaultTime;

  /// Days before a birthday to remind (0 = on the day); null = no birthday reminders.
  final int? birthdayDaysBefore;
}

/// Localized texts for notifications (implemented with AppLocalizations).
abstract interface class ReminderTexts {
  String birthdayTitle(String name, int? turningAge);
  String eventTitle(String title);
  String commitmentTitle(String name);

  /// e.g. "Today", "Tomorrow", "In 3 days" + the date (and time if any).
  String when(LocalDate date, {String? time, required LocalDate from});
}

/// Turns people, events and commitments into the notifications to schedule.
/// Android limits pending alarms, so only a rolling window is planned and the
/// plan is rebuilt on every app start and data change (ADR-017).
class ReminderPlanner {
  const ReminderPlanner(this._agenda, {this.horizonDays = 60, this.maxNotifications = 300});
  final AgendaService _agenda;
  final int horizonDays;
  final int maxNotifications;

  List<PlannedNotification> plan({
    required DateTime now,
    required ReminderSettings settings,
    required List<Person> people,
    required List<DateiEvent> events,
    required List<Commitment> commitments,
    required ReminderTexts texts,
  }) {
    if (!settings.enabled) return const [];
    final today = LocalDate.fromDateTime(now);
    final horizon = now.add(Duration(days: horizonDays));
    final out = <PlannedNotification>[];

    void add(String key, DateTime fireAt, String title, String body, String route) {
      if (!fireAt.isAfter(now) || fireAt.isAfter(horizon)) return;
      out.add(PlannedNotification(id: stableId(key), fireAt: fireAt, title: title, body: body, route: route));
    }

    DateTime at(LocalDate d, String hhmm) {
      final p = hhmm.split(':');
      return DateTime(d.year, d.month, d.day, int.parse(p[0]), int.parse(p[1]));
    }

    // Birthdays
    final birthdayDays = settings.birthdayDaysBefore;
    if (birthdayDays != null) {
      for (final item in _agenda.itemsInRange(
        people: people,
        events: const [],
        from: today,
        to: today.addDays(horizonDays + birthdayDays),
      )) {
        final p = item.person!;
        add(
          'birthday|${p.id}|${item.date}|$birthdayDays',
          at(item.date.addDays(-birthdayDays), settings.defaultTime),
          texts.birthdayTitle(p.shownName, item.turningAge),
          texts.when(item.date, from: item.date.addDays(-birthdayDays)),
          '/people/${p.id}',
        );
      }
    }

    // Events
    for (final e in events) {
      if (e.reminderMinutes.isEmpty || e.status == EventStatus.cancelled) continue;
      final maxOffsetDays = (e.reminderMinutes.reduce((a, b) => a > b ? a : b) / 1440).ceil();
      for (final occ in _agenda.eventOccurrences(e, today, today.addDays(horizonDays + maxOffsetDays))) {
        final anchor = at(occ.date, occ.time ?? settings.defaultTime);
        final route = e.isRecurring ? '/events/${e.id}/edit?occurrence=${occ.occurrenceDate}' : '/events/${e.id}/edit';
        for (final m in e.reminderMinutes) {
          final fire = anchor.subtract(Duration(minutes: m));
          add(
            'event|${e.id}|${occ.occurrenceDate}|$m',
            fire,
            texts.eventTitle(occ.title!),
            texts.when(occ.date, time: occ.time, from: LocalDate.fromDateTime(fire)),
            route,
          );
        }
      }
    }

    // Commitments
    for (final c in commitments) {
      if (c.lifecycle != CommitmentLifecycle.active) continue;
      for (final d in c.reminderDays) {
        final day = c.dueDate.addDays(-d);
        add(
          'commitment|${c.id}|${c.dueDate}|$d',
          at(day, settings.defaultTime),
          texts.commitmentTitle(c.name),
          texts.when(c.dueDate, from: day),
          '/commitments/${c.id}',
        );
      }
    }

    out.sort((a, b) => a.fireAt.compareTo(b.fireAt));
    final seen = <int>{};
    return [
      for (final n in out)
        if (seen.add(n.id)) n,
    ].take(maxNotifications).toList();
  }

  /// 31-bit FNV-1a hash: stable across runs and platforms (Dart's hashCode is not).
  static int stableId(String key) {
    var h = 0x811c9dc5;
    for (final c in key.codeUnits) {
      h ^= c;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h & 0x7FFFFFFF;
  }
}
