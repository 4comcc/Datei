import 'package:datei/app/bootstrap.dart';
import 'package:datei/core/recurrence_engine/recurrence.dart';
import 'package:datei/core/database/app_database.dart';
import 'package:datei/core/time_engine/local_date.dart';
import 'package:datei/features/events/data/drift_events_repository.dart';
import 'package:datei/features/events/domain/event.dart';
import 'package:datei/features/people/data/drift_people_repository.dart';
import 'package:datei/features/people/domain/person.dart';
import 'package:datei/features/settings/data/drift_settings_repository.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  late AppDatabase db;
  late DriftPeopleRepository people;
  late DriftEventsRepository events;
  final created = DateTime(2026, 1, 1);

  Person person(String id, String name, {List<String> cats = const [], String? birth}) => Person(
        id: id,
        fullName: name,
        categoryIds: cats.map((k) => 'sys:category:$k').toList(),
        birthDate: birth == null ? null : LocalDate.parse(birth),
        createdAt: created,
      );

  DateiEvent event(String id, {bool yearly = false, List<String> personIds = const []}) => DateiEvent(
        id: id,
        title: 'Event $id',
        typeId: EventType.anniversary.id,
        date: LocalDate.parse('2020-05-01'),
        recurrence: yearly ? const RecurrenceRule.yearly() : null,
        personIds: personIds,
        createdAt: created,
      );

  setUp(() async {
    db = openTestDatabase();
    final profileId = await ensureLocalProfile(db);
    people = DriftPeopleRepository(db, profileId);
    events = DriftEventsRepository(db, profileId);
  });
  tearDown(() => db.close());

  test('local profile is created once', () async {
    final a = await ensureLocalProfile(db);
    final b = await ensureLocalProfile(db);
    expect(a, b);
    expect(await db.select(db.localUserProfiles).get(), hasLength(1));
  });

  group('people', () {
    test('save → watch roundtrip with categories, sorted by shown name', () async {
      await people.save(person('b', 'Zed', cats: ['friends', 'family'], birth: '1990-02-28'));
      await people.save(person('a', 'amal'));
      final list = await people.watchAll().first;
      expect(list.map((p) => p.fullName), ['amal', 'Zed']);
      expect(list[1].categoryIds, ['sys:category:family', 'sys:category:friends']);
      expect(list[1].birthDate, LocalDate.parse('1990-02-28'));
    });

    test('update replaces categories and bumps row_version, keeps created_at', () async {
      await people.save(person('a', 'A', cats: ['friends']));
      final before = await (db.select(db.persons)..where((t) => t.id.equals('a'))).getSingle();
      await people.save(person('a', 'A2', cats: ['clients']));
      final after = await (db.select(db.persons)..where((t) => t.id.equals('a'))).getSingle();
      expect(after.rowVersion, before.rowVersion + 1);
      expect(after.createdAt, before.createdAt);
      final p = (await people.watchAll().first).single;
      expect(p.fullName, 'A2');
      expect(p.categoryIds, ['sys:category:clients']);
    });

    test('soft delete hides the person and unlinks events', () async {
      await people.save(person('a', 'A'));
      await events.save(event('e', personIds: ['a']));
      await people.delete('a');
      expect(await people.watchAll().first, isEmpty);
      final row = await (db.select(db.persons)..where((t) => t.id.equals('a'))).getSingle();
      expect(row.deletedAt, isNotNull);
      expect((await events.watchAll().first).single.personIds, isEmpty);
    });

    test('watch emits on change', () async {
      final stream = people.watchAll();
      final expectation = expectLater(stream.map((l) => l.length), emitsInOrder([0, 1]));
      await Future<void>.delayed(const Duration(milliseconds: 10));
      await people.save(person('a', 'A'));
      await expectation;
    });
  });

  group('events', () {
    test('yearly creates a recurrence rule; turning it off removes it', () async {
      await events.save(event('e', yearly: true));
      expect((await events.watchAll().first).single.isRecurring, isTrue);
      expect(await db.select(db.recurrenceRules).get(), hasLength(1));

      await events.save(event('e'));
      expect((await events.watchAll().first).single.isRecurring, isFalse);
      expect(await db.select(db.recurrenceRules).get(), isEmpty);
    });

    test('linked people roundtrip; unknown person ids are skipped', () async {
      await people.save(person('a', 'A'));
      await events.save(event('e', personIds: ['a', 'ghost']));
      expect((await events.watchAll().first).single.personIds, ['a']);
    });

    test('soft delete hides the event', () async {
      await events.save(event('e'));
      await events.delete('e');
      expect(await events.watchAll().first, isEmpty);
    });
  });

  group('constraints', () {
    test('end_date before start_date is rejected', () async {
      final profile = (await db.select(db.localUserProfiles).getSingle()).id;
      expect(
        () => db.into(db.events).insert(EventsCompanion.insert(
              id: 'x',
              ownerProfileId: profile,
              title: 't',
              eventTypeId: 'sys:event_type:other',
              startDate: '2026-02-02',
              endDate: const Value('2026-02-01'),
              createdAt: 0,
              updatedAt: 0,
            )),
        throwsA(isA<Exception>()),
      );
    });

    test('foreign keys are enforced', () async {
      expect(
        () => db.into(db.personCategoryRelations).insert(
              PersonCategoryRelationsCompanion.insert(personId: 'missing', categoryId: 'sys:category:family'),
            ),
        throwsA(isA<Exception>()),
      );
    });
  });

  test('erase all user data keeps settings, profile and system rows', () async {
    final settings = DriftSettingsRepository(db);
    await settings.set('general.language', 'ar');
    await people.save(person('a', 'A', cats: ['family']));
    await events.save(event('e', yearly: true, personIds: ['a']));

    await DriftDataMaintenanceRepository(db).eraseAllUserData();

    expect(await db.select(db.persons).get(), isEmpty);
    expect(await db.select(db.events).get(), isEmpty);
    expect(await db.select(db.recurrenceRules).get(), isEmpty);
    expect(await db.select(db.personCategories).get(), hasLength(6));
    expect(await db.select(db.localUserProfiles).get(), hasLength(1));
    expect((await settings.loadAll())['general.language'], 'ar');
  });
}
