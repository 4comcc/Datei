import 'person.dart';

abstract interface class PeopleRepository {
  /// Live list of non-deleted people, sorted by name.
  Stream<List<Person>> watchAll();

  /// Creates or updates [person] together with its category links.
  Future<void> save(Person person);

  /// Soft-deletes the person and removes their links to events.
  Future<void> delete(String id);
}
