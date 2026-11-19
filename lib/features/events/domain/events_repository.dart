import 'event.dart';

abstract interface class EventsRepository {
  /// Live list of non-deleted events.
  Stream<List<DateiEvent>> watchAll();

  /// Creates or updates [event] with its recurrence rule and linked people.
  Future<void> save(DateiEvent event);

  /// Soft-deletes the event.
  Future<void> delete(String id);
}
