import 'package:hijri/hijri_calendar.dart';

import 'local_date.dart';

/// A Hijri (Islamic) calendar date. Display/input only — Gregorian stays the
/// stored reference (CLAUDE.md rule 11).
class HijriDate {
  const HijriDate(this.year, this.month, this.day);
  final int year;
  final int month;
  final int day;

  @override
  bool operator ==(Object other) => other is HijriDate && other.year == year && other.month == month && other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => '$year-$month-$day AH';
}

/// Converts between Gregorian and Hijri using the Umm al-Qura table
/// (1356–1500 AH ≈ 1937–2077 CE), plus a user offset of −2…+2 days to match
/// local moon sighting. Outside the table range conversions return null.
class HijriConverter {
  const HijriConverter({this.offsetDays = 0}) : assert(offsetDays >= -2 && offsetDays <= 2);

  /// Added to the Hijri date (e.g. +1 when the local month started a day earlier than Umm al-Qura).
  final int offsetDays;

  static const minYear = 1356;
  static const maxYear = 1500;

  HijriDate? fromGregorian(LocalDate date) {
    final shifted = date.addDays(offsetDays);
    if (shifted.year < 1937 || shifted.year > 2077) return null;
    try {
      final h = HijriCalendar.fromDate(DateTime(shifted.year, shifted.month, shifted.day));
      if (h.hYear < minYear || h.hYear > maxYear) return null;
      return HijriDate(h.hYear, h.hMonth, h.hDay);
    } on ArgumentError {
      return null;
    }
  }

  LocalDate? toGregorian(HijriDate h) {
    if (h.year < minYear || h.year > maxYear || h.month < 1 || h.month > 12) return null;
    final length = daysInMonth(h.year, h.month);
    if (length == null || h.day < 1 || h.day > length) return null;
    try {
      final g = HijriCalendar().hijriToGregorian(h.year, h.month, h.day);
      return LocalDate(g.year, g.month, g.day).addDays(-offsetDays);
    } on ArgumentError {
      return null;
    }
  }

  /// 29 or 30 (Umm al-Qura), or null outside the supported range.
  int? daysInMonth(int year, int month) {
    if (year < minYear || year > maxYear || month < 1 || month > 12) return null;
    // The table needs the following month's start; the last month of 1500 AH is not available.
    if (year == maxYear && month == 12) return null;
    try {
      return HijriCalendar().getDaysInMonth(year, month);
    } on ArgumentError {
      // Also covers RangeError (a subtype) for dates at the edge of the table.
      return null;
    }
  }
}
