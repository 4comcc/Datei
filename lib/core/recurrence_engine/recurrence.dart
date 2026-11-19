import '../time_engine/time_engine.dart';

enum RecurrenceFrequency { daily, weekly, monthly, yearly }

/// What happens when a monthly date does not exist (e.g. the 31st in April).
enum MonthOverflow { clampToLastDay, skip }

/// A recurrence rule, RFC 5545-inspired. Only the rule is stored; occurrences
/// are computed (ADR-006).
///
/// - daily: every [interval] days.
/// - weekly: every [interval] weeks on [weekdays] (1 = Monday … 7 = Sunday);
///   empty means the start date's weekday.
/// - monthly: every [interval] months, either on day [monthDay] (default: the
///   start date's day) or, when [setPos] is set, on the setPos-th [weekdays]
///   weekday of the month (1…4, or -1 for the last), e.g. "last Friday".
/// - yearly: every [interval] years on the start date's month/day (Feb 29 per
///   [TimeEngine.feb29Policy]).
/// Ends after [count] occurrences or on [until] (inclusive), or never.
class RecurrenceRule {
  const RecurrenceRule({
    required this.frequency,
    this.interval = 1,
    this.weekdays = const {},
    this.monthDay,
    this.setPos,
    this.until,
    this.count,
    this.overflow = MonthOverflow.clampToLastDay,
  })  : assert(interval >= 1),
        assert(until == null || count == null, 'until and count are exclusive'),
        assert(count == null || count >= 1);

  const RecurrenceRule.yearly() : this(frequency: RecurrenceFrequency.yearly);

  final RecurrenceFrequency frequency;
  final int interval;
  final Set<int> weekdays;
  final int? monthDay;
  final int? setPos;
  final LocalDate? until;
  final int? count;
  final MonthOverflow overflow;

  bool get isNthWeekday => frequency == RecurrenceFrequency.monthly && setPos != null;

  RecurrenceRule copyWith({LocalDate? Function()? until, int? Function()? count}) => RecurrenceRule(
        frequency: frequency,
        interval: interval,
        weekdays: weekdays,
        monthDay: monthDay,
        setPos: setPos,
        until: until != null ? until() : this.until,
        count: count != null ? count() : this.count,
        overflow: overflow,
      );

  @override
  bool operator ==(Object other) =>
      other is RecurrenceRule &&
      other.frequency == frequency &&
      other.interval == interval &&
      other.weekdays.length == weekdays.length &&
      other.weekdays.containsAll(weekdays) &&
      other.monthDay == monthDay &&
      other.setPos == setPos &&
      other.until == until &&
      other.count == count &&
      other.overflow == overflow;

  @override
  int get hashCode => Object.hash(frequency, interval, Object.hashAllUnordered(weekdays), monthDay, setPos, until, count, overflow);
}

/// Expands recurrence rules into concrete dates. Pure and deterministic.
class RecurrenceEngine {
  const RecurrenceEngine([this._time = const TimeEngine()]);
  final TimeEngine _time;

  static const _maxIterations = 100000;

  /// Weekday of a date, 1 = Monday … 7 = Sunday.
  static int weekdayOf(LocalDate d) => d.toUtcDateTime().weekday;

  /// Occurrences of a series starting at [start] that fall within [from]..[to]
  /// (inclusive), in order. [excluded] dates still count toward [RecurrenceRule.count].
  Iterable<LocalDate> occurrences(
    LocalDate start,
    RecurrenceRule rule, {
    required LocalDate from,
    required LocalDate to,
    Set<LocalDate> excluded = const {},
  }) sync* {
    if (to.isBefore(from)) return;
    var produced = 0;
    for (final d in _candidates(start, rule, skipTo: rule.count == null ? from : null)) {
      if (rule.until != null && d.isAfter(rule.until!)) return;
      if (rule.count != null && produced >= rule.count!) return;
      produced++;
      if (d.isAfter(to)) return;
      if (d.isBefore(from) || excluded.contains(d)) continue;
      yield d;
    }
  }

  /// The first occurrence on or after [from], or null if the series has ended.
  LocalDate? nextOccurrence(LocalDate start, RecurrenceRule rule, LocalDate from, {Set<LocalDate> excluded = const {}}) {
    for (final d in occurrences(start, rule, from: from, to: from.addDays(366 * 5 * rule.interval), excluded: excluded)) {
      return d;
    }
    return null;
  }

  /// Number of occurrences strictly before [date] (used to split a counted series).
  int countBefore(LocalDate start, RecurrenceRule rule, LocalDate date) {
    var n = 0;
    for (final d in _candidates(start, rule)) {
      if (!d.isBefore(date)) break;
      if (rule.until != null && d.isAfter(rule.until!)) break;
      if (rule.count != null && n >= rule.count!) break;
      n++;
    }
    return n;
  }

  /// Unbounded, ordered candidate dates (before until/count). [skipTo] lets
  /// uncounted series jump close to a far-away window instead of iterating.
  Iterable<LocalDate> _candidates(LocalDate start, RecurrenceRule rule, {LocalDate? skipTo}) sync* {
    var guard = 0;
    switch (rule.frequency) {
      case RecurrenceFrequency.daily:
        var k = 0;
        if (skipTo != null && skipTo.isAfter(start)) k = start.daysUntil(skipTo) ~/ rule.interval;
        while (guard++ < _maxIterations) {
          yield start.addDays(k * rule.interval);
          k++;
        }
      case RecurrenceFrequency.weekly:
        final days = (rule.weekdays.isEmpty ? {weekdayOf(start)} : rule.weekdays).toList()..sort();
        // Monday of the start week.
        final week0 = start.addDays(-(weekdayOf(start) - 1));
        var w = 0;
        if (skipTo != null && skipTo.isAfter(start)) {
          w = (week0.daysUntil(skipTo) ~/ 7) ~/ rule.interval;
        }
        while (guard++ < _maxIterations) {
          final monday = week0.addDays(w * 7 * rule.interval);
          for (final wd in days) {
            final d = monday.addDays(wd - 1);
            if (!d.isBefore(start)) yield d;
          }
          w++;
        }
      case RecurrenceFrequency.monthly:
        final first = LocalDate(start.year, start.month, 1);
        var m = 0;
        if (skipTo != null && skipTo.isAfter(start)) {
          final months = (skipTo.year - start.year) * 12 + (skipTo.month - start.month) - 1;
          if (months > 0) m = months ~/ rule.interval;
        }
        while (guard++ < _maxIterations) {
          final monthStart = first.addMonths(m * rule.interval);
          final d = rule.isNthWeekday ? _nthWeekday(monthStart, rule) : _monthDay(monthStart, rule, start);
          if (d != null && !d.isBefore(start)) yield d;
          m++;
        }
      case RecurrenceFrequency.yearly:
        var y = 0;
        if (skipTo != null && skipTo.year > start.year) y = (skipTo.year - start.year - 1) ~/ rule.interval;
        while (guard++ < _maxIterations) {
          final year = start.year + y * rule.interval;
          yield y == 0 ? start : _time.anniversaryInYear(start, year);
          y++;
        }
    }
  }

  LocalDate? _monthDay(LocalDate monthStart, RecurrenceRule rule, LocalDate start) {
    final wanted = rule.monthDay ?? start.day;
    final length = LocalDate.daysInMonth(monthStart.year, monthStart.month);
    if (wanted > length) {
      return rule.overflow == MonthOverflow.skip ? null : LocalDate(monthStart.year, monthStart.month, length);
    }
    return LocalDate(monthStart.year, monthStart.month, wanted);
  }

  LocalDate? _nthWeekday(LocalDate monthStart, RecurrenceRule rule) {
    final wd = rule.weekdays.isEmpty ? null : rule.weekdays.first;
    if (wd == null) return null;
    final length = LocalDate.daysInMonth(monthStart.year, monthStart.month);
    final pos = rule.setPos!;
    if (pos > 0) {
      final firstMatch = monthStart.addDays((wd - weekdayOf(monthStart) + 7) % 7);
      final d = firstMatch.addDays((pos - 1) * 7);
      return d.month == monthStart.month ? d : null;
    }
    final monthEnd = LocalDate(monthStart.year, monthStart.month, length);
    return monthEnd.addDays(-((weekdayOf(monthEnd) - wd + 7) % 7));
  }
}
