import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/time_engine/local_date.dart';
import '../domain/people_repository.dart';
import '../domain/person.dart';

class DriftPeopleRepository implements PeopleRepository {
  DriftPeopleRepository(this._db, this._profileId);
  final AppDatabase _db;
  final String _profileId;

  static const _selectSql = '''
SELECT p.*,
  (SELECT group_concat(r.category_id) FROM person_category_relations r WHERE r.person_id = p.id) AS category_ids,
  (SELECT json_group_object(v.definition_id, v.value) FROM custom_field_values v WHERE v.entity_id = p.id) AS custom_fields
FROM persons p
WHERE p.deleted_at IS NULL
ORDER BY COALESCE(NULLIF(p.display_name, ''), p.full_name) COLLATE NOCASE
''';

  @override
  Stream<List<Person>> watchAll() => _db
      .customSelect(_selectSql, readsFrom: {_db.persons, _db.personCategoryRelations, _db.customFieldValues})
      .watch()
      .asyncMap((rows) async => [
            for (final row in rows)
              _toDomain(
                await _db.persons.mapFromRow(row),
                row.readNullable<String>('category_ids'),
                row.readNullable<String>('custom_fields'),
              ),
          ]);

  Person _toDomain(PersonRow r, String? categoryIds, String? customFieldsJson) => Person(
        id: r.id,
        fullName: r.fullName,
        displayName: r.displayName,
        birthDate: r.birthDate == null ? null : LocalDate.parse(r.birthDate!),
        birthYearKnown: r.birthYearKnown,
        gender: Gender.values.asNameMap()[r.gender],
        phone: r.phone,
        email: r.email,
        address: r.address,
        occupation: r.occupation,
        organization: r.organization,
        notes: r.notes,
        categoryIds: (categoryIds ?? '').split(',').where((s) => s.isNotEmpty).toList()..sort(),
        customFields: customFieldsJson == null
            ? const {}
            : (jsonDecode(customFieldsJson) as Map<String, dynamic>).map((k, v) => MapEntry(k, '$v')),
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true).toLocal(),
      );

  @override
  Future<void> save(Person person) => _db.transaction(() async {
        final now = nowUtcMs();
        final existing = await (_db.select(_db.persons)..where((t) => t.id.equals(person.id))).getSingleOrNull();
        final birth = person.birthDate;
        final storedBirth = birth == null
            ? null
            : person.birthYearKnown
                ? birth
                : LocalDate(unknownBirthYearPlaceholder, birth.month, birth.day);
        await _db.into(_db.persons).insertOnConflictUpdate(PersonsCompanion.insert(
              id: person.id,
              ownerProfileId: existing?.ownerProfileId ?? _profileId,
              fullName: person.fullName,
              displayName: Value(person.displayName),
              birthDate: Value(storedBirth?.toIso()),
              birthYearKnown: Value(person.birthYearKnown),
              gender: Value(person.gender?.name),
              phone: Value(person.phone),
              email: Value(person.email),
              address: Value(person.address),
              occupation: Value(person.occupation),
              organization: Value(person.organization),
              notes: Value(person.notes),
              createdAt: existing?.createdAt ?? person.createdAt.toUtc().millisecondsSinceEpoch,
              updatedAt: now,
              rowVersion: Value((existing?.rowVersion ?? 0) + 1),
            ));

        await (_db.delete(_db.personCategoryRelations)..where((t) => t.personId.equals(person.id))).go();
        for (final categoryId in person.categoryIds.toSet()) {
          // Ignore links to categories that no longer exist.
          final exists = await (_db.select(_db.personCategories)..where((t) => t.id.equals(categoryId))).getSingleOrNull();
          if (exists == null) continue;
          await _db.into(_db.personCategoryRelations).insert(
                PersonCategoryRelationsCompanion.insert(personId: person.id, categoryId: categoryId),
                mode: InsertMode.insertOrIgnore,
              );
        }

        await (_db.delete(_db.customFieldValues)..where((t) => t.entityId.equals(person.id))).go();
        for (final MapEntry(key: definitionId, :value) in person.customFields.entries) {
          if (value.trim().isEmpty) continue;
          final def = await (_db.select(_db.customFieldDefinitions)..where((t) => t.id.equals(definitionId)))
              .getSingleOrNull();
          if (def == null) continue;
          await _db.into(_db.customFieldValues).insert(
                CustomFieldValuesCompanion.insert(definitionId: definitionId, entityId: person.id, value: value.trim()),
              );
        }
      });

  @override
  Future<void> delete(String id) => _db.transaction(() async {
        final now = nowUtcMs();
        await (_db.update(_db.persons)..where((t) => t.id.equals(id))).write(
          PersonsCompanion.custom(
            deletedAt: Constant(now),
            updatedAt: Constant(now),
            rowVersion: _db.persons.rowVersion + const Constant(1),
          ),
        );
        await (_db.delete(_db.eventPersonRelations)..where((t) => t.personId.equals(id))).go();
        await (_db.delete(_db.personRelationships)
              ..where((t) => t.personId.equals(id) | t.relatedPersonId.equals(id)))
            .go();
      });
}
