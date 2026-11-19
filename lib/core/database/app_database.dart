import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

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
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Production database stored in the app's documents directory.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'datei'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        // Future versions: generated step-by-step migrations (drift_dev make-migrations).
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          await seedSystemData(this);
        },
      );
}
