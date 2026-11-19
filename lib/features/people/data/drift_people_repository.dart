import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_providers.dart';
import '../../../core/database/seed_data.dart';
import '../../../core/time_engine/local_date.dart';
import '../domain/people_repository.dart';
import '../domain/person.dart';

class DriftPeopleRepository implements PeopleRepository {
  DriftPeopleRepository(this._db, this._profileId);
  final AppDatabase _db;
  final String _profileId;

  static const _selectSql = '''
SELECT p.*,
  (SELECT group_concat(c.system_key) FROM person_category_relations r
     JOIN person_categories c ON c.id = r.category_id
    WHERE r.person_id = p.id) AS category_keys
FROM persons p
WHERE p.deleted_at IS NULL
ORDER BY COALESCE(NULLIF(p.display_name, ''), p.full_name) COLLATE NOCASE
''';

  @override
  Stream<List<Person>> watchAll() => _db
      .customSelect(_selectSql, readsFrom: {_db.persons, _db.personCategoryRelations, _db.personCategories})
      .watch()
      .asyncMap((rows) async => [
            for (final row in rows)
              _toDomain(await _db.persons.mapFromRow(row), row.readNullable<String>('category_keys')),
          ]);

  Person _toDomain(PersonRow r, String? categoryKeys) => Person(
        id: r.id,
        fullName: r.fullName,
        displayName: r.displayName,
        birthDate: r.birthDate == null ? null : LocalDate.parse(r.birthDate!),
        phone: r.phone,
        email: r.email,
        occupation: r.occupation,
        notes: r.notes,
        categories: [
          for (final k in (categoryKeys ?? '').split(',').where((k) => k.isNotEmpty))
            ?PersonCategory.values.asNameMap()[k],
        ]..sort((a, b) => a.index.compareTo(b.index)),
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt, isUtc: true).toLocal(),
      );

  @override
  Future<void> save(Person person) => _db.transaction(() async {
        final now = nowUtcMs();
        final existing =
            await (_db.select(_db.persons)..where((t) => t.id.equals(person.id))).getSingleOrNull();
        await _db.into(_db.persons).insertOnConflictUpdate(PersonsCompanion.insert(
              id: person.id,
              ownerProfileId: existing?.ownerProfileId ?? _profileId,
              fullName: person.fullName,
              displayName: Value(person.displayName),
              birthDate: Value(person.birthDate?.toIso()),
              phone: Value(person.phone),
              email: Value(person.email),
              occupation: Value(person.occupation),
              notes: Value(person.notes),
              createdAt: existing?.createdAt ?? person.createdAt.toUtc().millisecondsSinceEpoch,
              updatedAt: now,
              rowVersion: Value((existing?.rowVersion ?? 0) + 1),
            ));
        await (_db.delete(_db.personCategoryRelations)..where((t) => t.personId.equals(person.id))).go();
        for (final c in person.categories) {
          await _db.into(_db.personCategoryRelations).insert(
                PersonCategoryRelationsCompanion.insert(personId: person.id, categoryId: systemCategoryId(c.name)),
                mode: InsertMode.insertOrIgnore,
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
      });
}
