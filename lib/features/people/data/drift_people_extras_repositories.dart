import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../domain/category.dart';
import '../domain/custom_field.dart';
import '../domain/people_filter.dart';
import '../domain/people_repository.dart';
import '../domain/relationship.dart';

class DriftCategoriesRepository implements CategoriesRepository {
  DriftCategoriesRepository(this._db);
  final AppDatabase _db;

  @override
  Stream<List<PersonCategoryInfo>> watchAll() => (_db.select(_db.personCategories)
        ..orderBy([(t) => OrderingTerm.desc(t.isSystem), (t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.createdAt)]))
      .watch()
      .map((rows) => [
            for (final r in rows)
              PersonCategoryInfo(id: r.id, systemKey: r.systemKey, name: r.name, color: r.color, sortOrder: r.sortOrder),
          ]);

  @override
  Future<PersonCategoryInfo> create(String name, {int? color}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Category name is required');
    final now = nowUtcMs();
    final maxOrder = await (_db.selectOnly(_db.personCategories)..addColumns([_db.personCategories.sortOrder.max()]))
        .map((r) => r.read(_db.personCategories.sortOrder.max()))
        .getSingle();
    final id = const Uuid().v4();
    final order = (maxOrder ?? 0) + 1;
    await _db.into(_db.personCategories).insert(PersonCategoriesCompanion.insert(
          id: id,
          name: Value(trimmed),
          color: Value(color),
          sortOrder: Value(order),
          createdAt: now,
          updatedAt: now,
        ));
    return PersonCategoryInfo(id: id, name: trimmed, color: color, sortOrder: order);
  }

  @override
  Future<void> rename(String id, String name, {int? color}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) throw ArgumentError('Category name is required');
    await (_db.update(_db.personCategories)..where((t) => t.id.equals(id) & t.isSystem.equals(false))).write(
      PersonCategoriesCompanion(name: Value(trimmed), color: Value(color), updatedAt: Value(nowUtcMs())),
    );
  }

  @override
  Future<void> delete(String id) =>
      (_db.delete(_db.personCategories)..where((t) => t.id.equals(id) & t.isSystem.equals(false))).go();
}

class DriftRelationshipsRepository implements RelationshipsRepository {
  DriftRelationshipsRepository(this._db);
  final AppDatabase _db;

  @override
  Stream<List<Relationship>> watchAll() => (_db.select(_db.personRelationships)
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .watch()
      .map((rows) => [
            for (final r in rows)
              Relationship(
                id: r.id,
                personId: r.personId,
                relatedPersonId: r.relatedPersonId,
                type: RelationshipType.values.asNameMap()[r.relationType] ?? RelationshipType.custom,
                customLabel: r.customLabel,
              ),
          ]);

  @override
  Future<void> add(Relationship rel) async {
    if (rel.relatedPersonId == rel.personId) throw ArgumentError('A person cannot be related to themselves');
    final label = rel.customLabel?.trim();
    if (rel.type == RelationshipType.custom && (label == null || label.isEmpty)) {
      throw ArgumentError('Custom relationships need a label');
    }
    final now = nowUtcMs();
    await _db.into(_db.personRelationships).insert(PersonRelationshipsCompanion.insert(
          id: rel.id,
          personId: rel.personId,
          relatedPersonId: Value(rel.relatedPersonId),
          relationType: rel.type.name,
          customLabel: Value(rel.type == RelationshipType.custom ? label : null),
          createdAt: now,
          updatedAt: now,
        ));
  }

  @override
  Future<void> delete(String id) => (_db.delete(_db.personRelationships)..where((t) => t.id.equals(id))).go();
}

class DriftCustomFieldsRepository implements CustomFieldsRepository {
  DriftCustomFieldsRepository(this._db);
  final AppDatabase _db;

  @override
  Stream<List<CustomFieldDefinition>> watchDefinitions() => (_db.select(_db.customFieldDefinitions)
        ..where((t) => t.entityType.equals('person'))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.createdAt)]))
      .watch()
      .map((rows) => [
            for (final r in rows)
              CustomFieldDefinition(
                id: r.id,
                label: r.label,
                type: CustomFieldType.values.asNameMap()[r.fieldType] ?? CustomFieldType.text,
                sortOrder: r.sortOrder,
              ),
          ]);

  @override
  Future<void> saveDefinition(CustomFieldDefinition d) async {
    final label = d.label.trim();
    if (label.isEmpty) throw ArgumentError('Field label is required');
    final now = nowUtcMs();
    final existing =
        await (_db.select(_db.customFieldDefinitions)..where((t) => t.id.equals(d.id))).getSingleOrNull();
    await _db.into(_db.customFieldDefinitions).insertOnConflictUpdate(CustomFieldDefinitionsCompanion.insert(
          id: d.id,
          label: label,
          fieldType: Value(d.type.name),
          sortOrder: Value(d.sortOrder),
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
        ));
  }

  @override
  Future<void> deleteDefinition(String id) =>
      (_db.delete(_db.customFieldDefinitions)..where((t) => t.id.equals(id))).go();
}

class DriftSavedPeopleFiltersRepository implements SavedPeopleFiltersRepository {
  DriftSavedPeopleFiltersRepository(this._db);
  final AppDatabase _db;

  @override
  Stream<List<SavedPeopleFilter>> watchAll() => (_db.select(_db.savedFilters)
        ..where((t) => t.scope.equals('people'))
        ..orderBy([(t) => OrderingTerm.asc(t.sortOrder), (t) => OrderingTerm.asc(t.createdAt)]))
      .watch()
      .map((rows) => [
            for (final r in rows)
              SavedPeopleFilter(
                id: r.id,
                name: r.name,
                filter: PeopleFilter.fromJson(jsonDecode(r.definition) as Map<String, dynamic>),
              ),
          ]);

  @override
  Future<void> save(SavedPeopleFilter f) async {
    final name = f.name.trim();
    if (name.isEmpty) throw ArgumentError('Filter name is required');
    final now = nowUtcMs();
    final existing = await (_db.select(_db.savedFilters)..where((t) => t.id.equals(f.id))).getSingleOrNull();
    await _db.into(_db.savedFilters).insertOnConflictUpdate(SavedFiltersCompanion.insert(
          id: f.id,
          scope: 'people',
          name: name,
          definition: jsonEncode(f.filter.toJson()),
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
        ));
  }

  @override
  Future<void> delete(String id) => (_db.delete(_db.savedFilters)..where((t) => t.id.equals(id))).go();
}
