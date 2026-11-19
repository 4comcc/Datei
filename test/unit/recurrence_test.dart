import 'package:datei/core/recurrence_engine/recurrence.dart';
import 'package:datei/core/time_engine/time_engine.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const engine = RecurrenceEngine();
  LocalDate d(String s) => LocalDate.parse(s);
  List<String> occ(String start, RecurrenceRule rule, String from, String to, {Set<String> ex = const {}}) => engine
      .occurrences(d(start), rule, from: d(from), to: d(to), excluded: ex.map(d).toSet())
      .map((x) => x.toIso())
      .toList();

  group('daily', () {
    test('every 2 days', () {
      expect(occ('2026-01-30', const RecurrenceRule(frequency: RecurrenceFrequency.daily, interval: 2), '2026-01-01', '2026-02-05'),
          ['2026-01-30', '2026-02-01', '2026-02-03', '2026-02-05']);
    });
    test('far window jumps without iterating from the start, stays aligned', () {
      final r = engine.occurrences(d('1990-01-01'), const RecurrenceRule(frequency: RecurrenceFrequency.daily, interval: 3),
          from: d('2026-11-19'), to: d('2026-11-25'));
      for (final x in r) {
        expect(d('1990-01-01').daysUntil(x) % 3, 0);
      }
      expect(r, hasLength(2));
    });
  });

  group('weekly', () {
    test('Mon/Wed/Fri, starting on a Wednesday', () {
      // 2026-11-18 is a Wednesday.
      expect(occ('2026-11-18', const RecurrenceRule(frequency: RecurrenceFrequency.weekly, weekdays: {1, 3, 5}), '2026-11-01', '2026-11-30'),
          ['2026-11-18', '2026-11-20', '2026-11-23', '2026-11-25', '2026-11-27', '2026-11-30']);
    });
    test('every 2 weeks defaults to the start weekday', () {
      expect(occ('2026-11-19', const RecurrenceRule(frequency: RecurrenceFrequency.weekly, interval: 2), '2026-11-01', '2026-12-31'),
          ['2026-11-19', '2026-12-03', '2026-12-17', '2026-12-31']);
    });
    test('biweekly stays aligned across a far window', () {
      final r = engine.occurrences(d('2020-01-02'), const RecurrenceRule(frequency: RecurrenceFrequency.weekly, interval: 2),
          from: d('2026-11-01'), to: d('2026-11-30'));
      for (final x in r) {
        expect(d('2020-01-02').daysUntil(x) % 14, 0);
      }
      expect(r, isNotEmpty);
    });
  });

  group('monthly', () {
    test('31st clamps to month end by default', () {
      expect(occ('2026-01-31', const RecurrenceRule(frequency: RecurrenceFrequency.monthly), '2026-01-01', '2026-05-31'),
          ['2026-01-31', '2026-02-28', '2026-03-31', '2026-04-30', '2026-05-31']);
    });
    test('31st skips short months when asked', () {
      expect(
          occ('2026-01-31', const RecurrenceRule(frequency: RecurrenceFrequency.monthly, overflow: MonthOverflow.skip),
              '2026-01-01', '2026-05-31'),
          ['2026-01-31', '2026-03-31', '2026-05-31']);
    });
    test('second Tuesday and last Friday', () {
      expect(
          occ('2026-01-01', const RecurrenceRule(frequency: RecurrenceFrequency.monthly, setPos: 2, weekdays: {2}),
              '2026-01-01', '2026-03-31'),
          ['2026-01-13', '2026-02-10', '2026-03-10']);
      expect(
          occ('2026-01-01', const RecurrenceRule(frequency: RecurrenceFrequency.monthly, setPos: -1, weekdays: {5}),
              '2026-01-01', '2026-03-31'),
          ['2026-01-30', '2026-02-27', '2026-03-27']);
    });
    test('fifth Monday only in months that have one', () {
      // setPos 4 is the max in the UI, but the engine must not spill into the next month.
      final r = occ('2026-01-01', const RecurrenceRule(frequency: RecurrenceFrequency.monthly, setPos: 5, weekdays: {1}),
          '2026-01-01', '2026-12-31');
      for (final x in r) {
        expect(d(x).day, greaterThan(28));
      }
    });
    test('every 3 months', () {
      expect(occ('2026-01-15', const RecurrenceRule(frequency: RecurrenceFrequency.monthly, interval: 3), '2026-01-01', '2026-12-31'),
          ['2026-01-15', '2026-04-15', '2026-07-15', '2026-10-15']);
    });
  });

  group('yearly', () {
    test('Feb 29 observed on Feb 28 in common years', () {
      expect(occ('2024-02-29', const RecurrenceRule.yearly(), '2024-01-01', '2028-12-31'),
          ['2024-02-29', '2025-02-28', '2026-02-28', '2027-02-28', '2028-02-29']);
    });
    test('Feb 29 on Mar 1 with the mar1 policy', () {
      const e = RecurrenceEngine(TimeEngine(feb29Policy: Feb29Policy.mar1));
      expect(e.occurrences(d('2024-02-29'), const RecurrenceRule.yearly(), from: d('2025-01-01'), to: d('2025-12-31')).single,
          d('2025-03-01'));
    });
  });

  group('end conditions and exceptions', () {
    test('count limits total occurrences, including ones before the window', () {
      const r = RecurrenceRule(frequency: RecurrenceFrequency.daily, count: 5);
      expect(occ('2026-11-01', r, '2026-11-03', '2026-12-31'), ['2026-11-03', '2026-11-04', '2026-11-05']);
    });
    test('until is inclusive', () {
      final r = RecurrenceRule(frequency: RecurrenceFrequency.weekly, until: d('2026-11-26'));
      expect(occ('2026-11-12', r, '2026-11-01', '2026-12-31'), ['2026-11-12', '2026-11-19', '2026-11-26']);
    });
    test('excluded dates are skipped but still consume the count', () {
      const r = RecurrenceRule(frequency: RecurrenceFrequency.daily, count: 3);
      expect(occ('2026-11-01', r, '2026-11-01', '2026-11-30', ex: {'2026-11-02'}), ['2026-11-01', '2026-11-03']);
    });
    test('nextOccurrence and countBefore', () {
      const r = RecurrenceRule(frequency: RecurrenceFrequency.weekly);
      expect(engine.nextOccurrence(d('2026-11-05'), r, d('2026-11-20')), d('2026-11-26'));
      expect(engine.countBefore(d('2026-11-05'), r, d('2026-11-26')), 3);
      expect(engine.nextOccurrence(d('2026-11-05'), const RecurrenceRule(frequency: RecurrenceFrequency.daily, count: 2), d('2026-12-01')),
          isNull);
    });
    test('empty window and windows before the start', () {
      expect(occ('2026-11-19', const RecurrenceRule.yearly(), '2026-12-01', '2026-11-01'), isEmpty);
      expect(occ('2026-11-19', const RecurrenceRule.yearly(), '2020-01-01', '2025-12-31'), isEmpty);
    });
  });
}
