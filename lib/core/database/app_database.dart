import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'app_database.steps.dart';
import 'seed_data.dart';
import 'tables.dart';

export 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  LocalUserProfiles,
  AccountMetadata,
  AppSettings,
  Persons,
  PersonCategories,
  PersonCategoryRelations,
  EventTypes,
  RecurrenceRules,
  Events,
  EventPersonRelations,
  PersonRelationships,
  CustomFieldDefinitions,
  CustomFieldValues,
  SavedFilters,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Production database stored in the app's documents directory.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'datei'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: stepByStep(
          from1To2: (m, schema) async {
            await m.addColumn(schema.persons, schema.persons.birthYearKnown);
            await m.createTable(schema.personRelationships);
            await m.createIndex(schema.idxRelPerson);
            await m.createIndex(schema.idxRelRelated);
            await m.createTable(schema.customFieldDefinitions);
            await m.createTable(schema.customFieldValues);
            await m.createTable(schema.savedFilters);
          },
        ),
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await seedSystemData(this);
        },
      );
}
