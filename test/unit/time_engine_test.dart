import 'package:datei/core/time_engine/time_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = TimeEngine();
  LocalDate d(String s) => LocalDate.parse(s);

  group('LocalDate', () {
    test('parse/format roundtrip and validation', () {
      expect(d('2024-02-29').toIso(), '2024-02-29');
      expect(() => d('2023-02-29'), throwsFormatException);
      expect(() => d('2023-13-01'), throwsFormatException);
    });
    test('addMonths clamps to month end', () {
      expect(d('2025-01-31').addMonths(1), d('2025-02-28'));
      expect(d('2024-01-31').addMonths(1), d('2024-02-29'));
      expect(d('2025-12-15').addMonths(1), d('2026-01-15'));
    });
    test('daysUntil across leap day', () {
      expect(d('2024-02-28').daysUntil(d('2024-03-01')), 2);
      expect(d('2023-02-28').daysUntil(d('2023-03-01')), 1);
    });
  });

  group('age', () {
    test('simple age', () {
      expect(engine.ageOn(d('1990-05-10'), d('2026-05-09'))!.years, 35);
      expect(engine.ageOn(d('1990-05-10'), d('2026-05-10'))!.years, 36);
    });
    test('breakdown', () {
      expect(engine.ageOn(d('2000-01-15'), d('2026-03-20')), const AgeBreakdown(26, 2, 5));
      expect(engine.ageOn(d('2000-01-31'), d('2000-03-01')), const AgeBreakdown(0, 1, 1));
    });
    test('before birth is null', () {
      expect(engine.ageOn(d('2026-01-01'), d('2025-12-31')), isNull);
    });
    test('Feb 29 birthday, feb28 policy', () {
      expect(engine.ageOn(d('2000-02-29'), d('2025-02-27'))!.years, 24);
      expect(engine.ageOn(d('2000-02-29'), d('2025-02-28'))!.years, 25);
      expect(engine.ageOn(d('2000-02-29'), d('2024-02-29'))!.years, 24);
    });
    test('Feb 29 birthday, mar1 policy', () {
      const e = TimeEngine(feb29Policy: Feb29Policy.mar1);
      expect(e.ageOn(d('2000-02-29'), d('2025-02-28'))!.years, 24);
      expect(e.ageOn(d('2000-02-29'), d('2025-03-01'))!.years, 25);
    });
  });

  group('next birthday', () {
    test('later this year / today / next year', () {
      expect(engine.nextBirthday(d('1990-12-25'), d('2026-11-19')), d('2026-12-25'));
      expect(engine.nextBirthday(d('1990-11-19'), d('2026-11-19')), d('2026-11-19'));
      expect(engine.nextBirthday(d('1990-01-02'), d('2026-11-19')), d('2027-01-02'));
      expect(engine.turningAge(d('1990-01-02'), d('2026-11-19')), 37);
    });
    test('leap day observed on Feb 28 in common years', () {
      expect(engine.nextBirthday(d('2000-02-29'), d('2026-01-01')), d('2026-02-28'));
      expect(engine.nextBirthday(d('2000-02-29'), d('2028-01-01')), d('2028-02-29'));
    });
    test('never returns the birth date itself', () {
      expect(engine.nextBirthday(d('2026-11-19'), d('2026-11-19')), d('2027-11-19'));
    });
  });

  test('yearly occurrences in range', () {
    final occ = engine.yearlyOccurrences(d('2020-03-10'), d('2019-01-01'), d('2022-12-31')).toList();
    expect(occ, [d('2020-03-10'), d('2021-03-10'), d('2022-03-10')]);
    final noOrigin = engine
        .yearlyOccurrences(d('2020-03-10'), d('2020-01-01'), d('2021-12-31'), includeOrigin: false)
        .toList();
    expect(noOrigin, [d('2021-03-10')]);
  });
}
