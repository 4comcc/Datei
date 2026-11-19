import 'package:datei/app/bootstrap.dart';
import 'package:datei/core/database/app_database.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/people/data/drift_people_extras_repositories.dart';
import 'package:datei/features/people/data/drift_people_repository.dart';
import 'package:datei/features/people/domain/custom_field.dart';
import 'package:datei/features/people/domain/people_filter.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/people/domain/relationship.dart';
import 'package:datei/features/settings/data/drift_settings_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late DriftPeopleRepository people;
  late DriftCategoriesRepository categories;
  late DriftRelationshipsRepository relationships;
  late DriftCustomFieldsRepository fields;
  late DriftSavedPeopleFiltersRepository filters;
  final created = DateTime(2026);

  Person person(String id, {List<String> cats = const [], Map<String, String> custom = const {}}) =>
      Person(id: id, fullName: 'P $id', categoryIds: cats, customFields: custom, createdAt: created);

  setUp(() async {
    db = openTestDatabase();
    final profile = await ensureLocalProfile(db);
    people = DriftPeopleRepository(db, profile);
    categories = DriftCategoriesRepository(db);
    relationships = DriftRelationshipsRepository(db);
    fields = DriftCustomFieldsRepository(db);
    filters = DriftSavedPeopleFiltersRepository(db);
  });
  tearDown(() => db.close());

  group('categories', () {
    test('system first, then user categories; create/rename/delete', () async {
      final c = await categories.create('  Gym  ', color: 0xFF3F6F7A);
      expect(c.name, 'Gym');
      var list = await categories.watchAll().first;
      expect(list.take(6).every((x) => x.isSystem), isTrue);
      expect(list.last.name, 'Gym');

      await categories.rename(c.id, 'Club');
      list = await categories.watchAll().first;
      expect(list.last.name, 'Club');

      await people.save(person('a', cats: [c.id, 'sys:category:family']));
      await categories.delete(c.id);
      expect((await people.watchAll().first).single.categoryIds, ['sys:category:family']);
    });

    test('system categories cannot be renamed or deleted; empty names are rejected', () async {
      await categories.rename('sys:category:family', 'X');
      await categories.delete('sys:category:family');
      final fam = (await categories.watchAll().first).firstWhere((c) => c.id == 'sys:category:family');
      expect(fam.name, isNull);
      expect(() => categories.create('   '), throwsArgumentError);
    });
  });

  group('relationships', () {
    test('to me and to another person; not mirrored', () async {
      await people.save(person('a'));
      await people.save(person('b'));
      await relationships.add(const Relationship(id: 'r1', personId: 'a', type: RelationshipType.father));
      await relationships.add(const Relationship(id: 'r2', personId: 'a', relatedPersonId: 'b', type: RelationshipType.colleague));
      final all = await relationships.watchAll().first;
      expect(all, hasLength(2));
      expect(all.first.isToMe, isTrue);
      expect(all.where((r) => r.personId == 'b'), isEmpty);
    });

    test('validation: no self-relation; custom needs a label', () async {
      await people.save(person('a'));
      expect(
        () => relationships.add(const Relationship(id: 'x', personId: 'a', relatedPersonId: 'a', type: RelationshipType.friend)),
        throwsArgumentError,
      );
      expect(
        () => relationships.add(const Relationship(id: 'y', personId: 'a', type: RelationshipType.custom, customLabel: ' ')),
        throwsArgumentError,
      );
      await relationships.add(const Relationship(id: 'z', personId: 'a', type: RelationshipType.custom, customLabel: 'Mentor'));
      expect((await relationships.watchAll().first).single.customLabel, 'Mentor');
    });

    test('deleting a person removes relationships on both sides', () async {
      await people.save(person('a'));
      await people.save(person('b'));
      await relationships.add(const Relationship(id: 'r', personId: 'b', relatedPersonId: 'a', type: RelationshipType.son));
      await people.delete('a');
      expect(await relationships.watchAll().first, isEmpty);
    });
  });

  group('custom fields', () {
    test('values roundtrip through person save; deleting a definition removes values', () async {
      await fields.saveDefinition(const CustomFieldDefinition(id: 'blood', label: 'Blood type'));
      await fields.saveDefinition(const CustomFieldDefinition(id: 'n', label: 'Number', type: CustomFieldType.number));
      await people.save(person('a', custom: {'blood': ' O+ ', 'n': '7', 'unknown': 'x', 'empty': ''}));
      expect((await people.watchAll().first).single.customFields, {'blood': 'O+', 'n': '7'});

      await fields.deleteDefinition('blood');
      expect((await people.watchAll().first).single.customFields, {'n': '7'});
      expect((await fields.watchDefinitions().first).single.type, CustomFieldType.number);
    });
  });

  test('birth date without year is stored with the placeholder year and flagged', () async {
    await people.save(Person(
      id: 'a',
      fullName: 'A',
      birthDate: LocalDate.parse('1990-02-29'.replaceFirst('1990', '1992')),
      birthYearKnown: false,
      createdAt: created,
    ));
    final p = (await people.watchAll().first).single;
    expect(p.birthYearKnown, isFalse);
    expect(p.birthDate, LocalDate(unknownBirthYearPlaceholder, 2, 29));
    expect(p.birthDateWithYear, isNull);
  });

  test('saved filters roundtrip', () async {
    await filters.save(const SavedPeopleFilter(
      id: 'f',
      name: 'Family under 30',
      filter: PeopleFilter(categoryIds: {'sys:category:family'}, maxAge: 29, relationType: RelationshipType.sister),
    ));
    final s = (await filters.watchAll().first).single;
    expect(s.name, 'Family under 30');
    expect(s.filter.maxAge, 29);
    expect(s.filter.categoryIds, {'sys:category:family'});
    expect(s.filter.relationType, RelationshipType.sister);
    await filters.delete('f');
    expect(await filters.watchAll().first, isEmpty);
  });

  test('erase all removes relationships and custom values, keeps field definitions', () async {
    await fields.saveDefinition(const CustomFieldDefinition(id: 'blood', label: 'Blood'));
    await people.save(person('a', custom: {'blood': 'A'}));
    await people.save(person('b'));
    await relationships.add(const Relationship(id: 'r', personId: 'a', relatedPersonId: 'b', type: RelationshipType.friend));
    await DriftDataMaintenanceRepository(db).eraseAllUserData();
    expect(await db.select(db.personRelationships).get(), isEmpty);
    expect(await db.select(db.customFieldValues).get(), isEmpty);
    expect(await db.select(db.customFieldDefinitions).get(), hasLength(1));
  });
}
