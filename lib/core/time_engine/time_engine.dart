import 'local_date.dart';

export 'local_date.dart';

/// How a Feb 29 anniversary is observed in non-leap years (see ADR-009).
enum Feb29Policy { feb28, mar1 }

/// Age broken down into full years, months and days.
class AgeBreakdown {
  const AgeBreakdown(this.years, this.months, this.days);
  final int years;
  final int months;
  final int days;

  @override
  bool operator ==(Object other) =>
      other is AgeBreakdown && other.years == years && other.months == months && other.days == days;

  @override
  int get hashCode => Object.hash(years, months, days);

  @override
  String toString() => '${years}y ${months}m ${days}d';
}

/// Central, pure date calculations. All features must use this instead of
/// doing date math themselves.
class TimeEngine {
  const TimeEngine({this.feb29Policy = Feb29Policy.feb28});

  final Feb29Policy feb29Policy;

  /// The date on which an anniversary of [origin] is observed in [year].
  LocalDate anniversaryInYear(LocalDate origin, int year) {
    if (origin.month == 2 && origin.day == 29 && !LocalDate.isLeapYear(year)) {
      return feb29Policy == Feb29Policy.feb28 ? LocalDate(year, 2, 28) : LocalDate(year, 3, 1);
    }
    return LocalDate(year, origin.month, origin.day);
  }

  /// First anniversary of [origin] on or after [from] (never before [origin] itself).
  LocalDate nextAnniversary(LocalDate origin, LocalDate from) {
    final start = from.isBefore(origin) ? origin : from;
    var candidate = anniversaryInYear(origin, start.year);
    if (candidate.isBefore(start)) candidate = anniversaryInYear(origin, start.year + 1);
    return candidate;
  }

  /// Next birthday strictly after the birth date, on or after [from].
  LocalDate nextBirthday(LocalDate birthDate, LocalDate from) {
    final afterBirth = birthDate.addDays(1);
    return nextAnniversary(birthDate, from.isBefore(afterBirth) ? afterBirth : from);
  }

  /// Age reached on the next birthday on/after [from].
  int turningAge(LocalDate birthDate, LocalDate from) =>
      nextBirthday(birthDate, from).year - birthDate.year;

  /// Full age on [on]. Returns null if [on] is before [birthDate].
  AgeBreakdown? ageOn(LocalDate birthDate, LocalDate on) {
    if (on.isBefore(birthDate)) return null;
    var lastYear = on.year;
    var last = anniversaryInYear(birthDate, lastYear);
    if (last.isAfter(on)) {
      lastYear -= 1;
      last = lastYear < birthDate.year ? birthDate : anniversaryInYear(birthDate, lastYear);
    }
    final years = lastYear - birthDate.year;
    var months = 0;
    while (!last.addMonths(months + 1).isAfter(on)) {
      months++;
    }
    final days = last.addMonths(months).daysUntil(on);
    return AgeBreakdown(years, months, days);
  }

  /// Calendar difference from [from] to [to] in full years, months and days
  /// (month ends clamp: Jan 31 → Feb 28 counts as one month). Null if [to] < [from].
  AgeBreakdown? difference(LocalDate from, LocalDate to) {
    if (to.isBefore(from)) return null;
    var months = (to.year - from.year) * 12 + (to.month - from.month);
    if (from.addMonths(months).isAfter(to)) months--;
    final days = from.addMonths(months).daysUntil(to);
    return AgeBreakdown(months ~/ 12, months % 12, days);
  }

  /// Days elapsed from [from] to [to] (negative when [to] is earlier).
  int daysBetween(LocalDate from, LocalDate to) => from.daysUntil(to);

  /// Occurrences of a yearly anniversary of [origin] that fall in [rangeStart]..[rangeEnd] (inclusive).
  /// The origin date itself is included when it is in range.
  Iterable<LocalDate> yearlyOccurrences(
    LocalDate origin,
    LocalDate rangeStart,
    LocalDate rangeEnd, {
    bool includeOrigin = true,
  }) sync* {
    for (var y = rangeStart.year; y <= rangeEnd.year; y++) {
      if (y < origin.year || (y == origin.year && !includeOrigin)) continue;
      final d = y == origin.year ? origin : anniversaryInYear(origin, y);
      if (!d.isBefore(rangeStart) && !d.isAfter(rangeEnd)) yield d;
    }
  }
}
