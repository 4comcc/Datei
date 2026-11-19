import 'category.dart';
import 'custom_field.dart';
import 'people_filter.dart';
import 'person.dart';
import 'relationship.dart';

abstract interface class PeopleRepository {
  /// Live list of non-deleted people (with categories and custom field values), sorted by name.
  Stream<List<Person>> watchAll();

  /// Creates or updates [person] with its category links and custom field values.
  Future<void> save(Person person);

  /// Soft-deletes the person and removes their event links and relationships.
  Future<void> delete(String id);
}

abstract interface class CategoriesRepository {
  Stream<List<PersonCategoryInfo>> watchAll();
  Future<PersonCategoryInfo> create(String name, {int? color});
  Future<void> rename(String id, String name, {int? color});

  /// Deletes a user category (system categories cannot be deleted) and unlinks it from people.
  Future<void> delete(String id);
}

abstract interface class RelationshipsRepository {
  Stream<List<Relationship>> watchAll();
  Future<void> add(Relationship relationship);
  Future<void> delete(String id);
}

abstract interface class CustomFieldsRepository {
  Stream<List<CustomFieldDefinition>> watchDefinitions();
  Future<void> saveDefinition(CustomFieldDefinition definition);

  /// Deletes the field and every value stored for it.
  Future<void> deleteDefinition(String id);
}

abstract interface class SavedPeopleFiltersRepository {
  Stream<List<SavedPeopleFilter>> watchAll();
  Future<void> save(SavedPeopleFilter filter);
  Future<void> delete(String id);
}
