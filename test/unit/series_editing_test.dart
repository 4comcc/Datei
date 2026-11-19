import 'package:datei/core/recurrence_engine/recurrence.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/events/domain/series_editing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const s = SeriesEditing();
  LocalDate d(String x) => LocalDate.parse(x);

  test('uncounted weekly series splits into until + same rule', () {
    const rule = RecurrenceRule(frequency: RecurrenceFrequency.weekly);
    final r = s.split(d('2026-11-05'), rule, d('2026-11-26'));
    expect(r.before!.until, d('2026-11-25'));
    expect(r.after, rule);
  });

  test('counted series: remaining count moves to the new series', () {
    const rule = RecurrenceRule(frequency: RecurrenceFrequency.daily, count: 10);
    final r = s.split(d('2026-11-01'), rule, d('2026-11-04'));
    expect(r.before!.until, d('2026-11-03'));
    expect(r.before!.count, isNull);
    expect(r.after!.count, 7);
  });

  test('splitting at the first occurrence removes the original series', () {
    final r = s.split(d('2026-11-01'), const RecurrenceRule.yearly(), d('2026-11-01'));
    expect(r.before, isNull);
    expect(r.after, const RecurrenceRule.yearly());
  });

  test('splitting after the end leaves nothing for a new series', () {
    final r = s.split(d('2026-11-01'), RecurrenceRule(frequency: RecurrenceFrequency.daily, until: d('2026-11-03')), d('2026-11-10'));
    expect(r.after, isNull);
    final c = s.split(d('2026-11-01'), const RecurrenceRule(frequency: RecurrenceFrequency.daily, count: 2), d('2026-11-05'));
    expect(c.after, isNull);
  });
}
