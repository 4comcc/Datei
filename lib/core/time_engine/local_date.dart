/// A calendar date without time or time zone (e.g. a birthday or an all-day event).
///
/// Stored as `YYYY-MM-DD`. All arithmetic is done in UTC internally so that
/// daylight-saving transitions can never shift the day.
class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day);

  factory LocalDate.fromDateTime(DateTime dt) => LocalDate(dt.year, dt.month, dt.day);

  factory LocalDate.today([DateTime Function()? now]) =>
      LocalDate.fromDateTime((now ?? DateTime.now)());

  /// Parses `YYYY-MM-DD`. Throws [FormatException] on invalid input.
  factory LocalDate.parse(String iso) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(iso);
    if (match == null) throw FormatException('Invalid LocalDate', iso);
    final y = int.parse(match.group(1)!);
    final m = int.parse(match.group(2)!);
    final d = int.parse(match.group(3)!);
    if (m < 1 || m > 12 || d < 1 || d > daysInMonth(y, m)) {
      throw FormatException('Invalid LocalDate', iso);
    }
    return LocalDate(y, m, d);
  }

  final int year;
  final int month;
  final int day;

  static bool isLeapYear(int year) =>
      (year % 4 == 0 && year % 100 != 0) || year % 400 == 0;

  static int daysInMonth(int year, int month) {
    const lengths = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    if (month == 2 && isLeapYear(year)) return 29;
    return lengths[month - 1];
  }

  DateTime toUtcDateTime() => DateTime.utc(year, month, day);

  /// Local midnight; use only for UI pickers.
  DateTime toDateTime() => DateTime(year, month, day);

  LocalDate addDays(int days) =>
      LocalDate.fromDateTime(toUtcDateTime().add(Duration(days: days)));

  /// Adds months, clamping the day to the target month's length (Jan 31 + 1 month = Feb 28/29).
  LocalDate addMonths(int months) {
    final total = year * 12 + (month - 1) + months;
    final y = total ~/ 12;
    final m = total % 12 + 1;
    final d = day > daysInMonth(y, m) ? daysInMonth(y, m) : day;
    return LocalDate(y, m, d);
  }

  /// Number of days from `this` to [other] (positive if [other] is later).
  int daysUntil(LocalDate other) =>
      other.toUtcDateTime().difference(toUtcDateTime()).inDays;

  bool isBefore(LocalDate other) => compareTo(other) < 0;
  bool isAfter(LocalDate other) => compareTo(other) > 0;

  String toIso() =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalDate other) {
    if (year != other.year) return year.compareTo(other.year);
    if (month != other.month) return month.compareTo(other.month);
    return day.compareTo(other.day);
  }

  @override
  bool operator ==(Object other) =>
      other is LocalDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => toIso();
}
