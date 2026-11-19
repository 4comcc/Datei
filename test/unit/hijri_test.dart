import 'package:datei/core/time_engine/hijri.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const uq = HijriConverter();
  LocalDate d(String s) => LocalDate.parse(s);

  // Umm al-Qura month starts (official Saudi calendar).
  final known = <String, HijriDate>{
    '2024-07-07': const HijriDate(1446, 1, 1),
    '2025-03-01': const HijriDate(1446, 9, 1),
    '2025-03-30': const HijriDate(1446, 10, 1),
    '2025-06-26': const HijriDate(1447, 1, 1),
    '2026-02-18': const HijriDate(1447, 9, 1),
  };

  test('Gregorian → Hijri matches known Umm al-Qura dates', () {
    known.forEach((g, h) => expect(uq.fromGregorian(d(g)), h, reason: g));
  });

  test('Hijri → Gregorian is the inverse', () {
    known.forEach((g, h) => expect(uq.toGregorian(h), d(g), reason: '$h'));
  });

  test('roundtrip every day for two years', () {
    var day = d('2025-01-01');
    for (var i = 0; i < 730; i++) {
      final h = uq.fromGregorian(day)!;
      expect(uq.toGregorian(h), day);
      day = day.addDays(1);
    }
  });

  test('offset shifts the Hijri date, Gregorian stays the reference', () {
    const plusOne = HijriConverter(offsetDays: 1);
    expect(plusOne.fromGregorian(d('2025-02-28')), const HijriDate(1446, 9, 1));
    expect(plusOne.toGregorian(const HijriDate(1446, 9, 1)), d('2025-02-28'));
    const minusOne = HijriConverter(offsetDays: -1);
    expect(minusOne.fromGregorian(d('2025-03-02')), const HijriDate(1446, 9, 1));
  });

  test('month lengths are 29 or 30; invalid days rejected', () {
    for (var m = 1; m <= 12; m++) {
      expect(uq.daysInMonth(1447, m), anyOf(29, 30));
    }
    expect(uq.toGregorian(const HijriDate(1447, 13, 1)), isNull);
    expect(uq.toGregorian(const HijriDate(1447, 1, 31)), isNull);
  });

  test('outside the Umm al-Qura table returns null', () {
    expect(uq.fromGregorian(d('1900-01-01')), isNull);
    expect(uq.fromGregorian(d('2090-01-01')), isNull);
    expect(uq.toGregorian(const HijriDate(1300, 1, 1)), isNull);
  });
}
