import '../../../core/recurrence_engine/recurrence.dart';
import '../../../core/time_engine/local_date.dart';
import 'event.dart';

/// Which occurrences an edit or delete of a recurring event applies to.
enum EditScope { thisOccurrence, thisAndFollowing, all }

/// Result of splitting a series at an occurrence.
class SeriesSplit {
  const SeriesSplit({required this.before, required this.after});

  /// Rule for the original series, ending before the split date; null when no
  /// occurrence remains before it (the original series is then removed).
  final RecurrenceRule? before;

  /// Rule for the new series starting at the split date; null when the original
  /// series had no occurrence left from that date.
  final RecurrenceRule? after;
}

/// Pure series-splitting logic ("this and following"), shared by edit and delete.
class SeriesEditing {
  const SeriesEditing([this._engine = const RecurrenceEngine()]);
  final RecurrenceEngine _engine;

  SeriesSplit split(LocalDate start, RecurrenceRule rule, LocalDate at) {
    final before = _engine.countBefore(start, rule, at);
    final RecurrenceRule? oldRule = before == 0 ? null : rule.copyWith(until: () => at.addDays(-1), count: () => null);
    RecurrenceRule? newRule;
    if (rule.count != null) {
      final remaining = rule.count! - before;
      newRule = remaining > 0 ? rule.copyWith(count: () => remaining) : null;
    } else if (rule.until != null && at.isAfter(rule.until!)) {
      newRule = null;
    } else {
      newRule = rule;
    }
    return SeriesSplit(before: oldRule, after: newRule);
  }

  /// Exceptions that belong before [at] stay with the original series.
  List<EventException> exceptionsBefore(DateiEvent e, LocalDate at) =>
      [for (final x in e.exceptions) if (x.originalDate.isBefore(at)) x];
}
