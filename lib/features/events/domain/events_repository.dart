import '../../../core/time_engine/local_date.dart';
import 'event.dart';

abstract interface class EventsRepository {
  /// Live list of non-deleted events, with recurrence rules and exceptions.
  Stream<List<DateiEvent>> watchAll();

  /// Creates or updates [event] (whole series) with its rule and linked people.
  Future<void> save(DateiEvent event);

  /// Soft-deletes the event (whole series).
  Future<void> delete(String id);

  /// Overrides one occurrence of a recurring event.
  Future<void> overrideOccurrence(String eventId, LocalDate originalDate, OccurrenceOverride change);

  /// Cancels one occurrence of a recurring event.
  Future<void> cancelOccurrence(String eventId, LocalDate originalDate);

  /// "This and following": ends the original series before [at] (or deletes it
  /// if nothing remains) and, when [replacement] is given, saves it as a new
  /// series starting at [at] — all in one transaction.
  Future<void> splitSeries(String eventId, LocalDate at, {DateiEvent? replacement});
}

abstract interface class EventTypesRepository {
  Stream<List<EventTypeInfo>> watchAll();
  Future<EventTypeInfo> create(String name, {int? color});
  Future<void> rename(String id, String name, {int? color});

  /// Deletes a user type; its events move to the built-in "Other" type.
  Future<void> delete(String id);
}
