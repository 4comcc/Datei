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
  EventExceptions,
  CommitmentTypes,
  Commitments,
  CommitmentRenewals,
  Reminders,
  Tags,
  EntityTagRelations,
  Memories,
  MemoryPersonRelations,
  Projects,
  ProjectPersonRelations,
  ProjectEventRelations,
  Milestones,
  Attachments,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// Production database stored in the app's documents directory.
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'datei'));

  @override
  int get schemaVersion => 5;

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
          from2To3: (m, schema) async {
            await m.createTable(schema.eventExceptions);
            await m.createIndex(schema.idxEventExceptionsEvent);
          },
          from3To4: (m, schema) async {
            await m.createTable(schema.commitmentTypes);
            await m.createTable(schema.commitments);
            await m.createIndex(schema.idxCommitmentsExpiry);
            await m.createIndex(schema.idxCommitmentsDeletedAt);
            await m.createTable(schema.commitmentRenewals);
            await m.createIndex(schema.idxRenewalsCommitment);
            await m.createTable(schema.reminders);
            await m.createIndex(schema.idxRemindersOwner);
          },
          from4To5: (m, schema) async {
            for (final t in [
              schema.tags,
              schema.entityTagRelations,
              schema.memories,
              schema.memoryPersonRelations,
              schema.projects,
              schema.projectPersonRelations,
              schema.projectEventRelations,
              schema.milestones,
              schema.attachments,
            ]) {
              await m.createTable(t);
            }
            for (final i in [
              schema.idxEntityTagsEntity,
              schema.idxMemoriesDate,
              schema.idxMprPerson,
              schema.idxMilestonesDate,
              schema.idxAttachmentsOwner,
            ]) {
              await m.createIndex(i);
            }
          },
        ),
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          // Seed only at the current schema (migration tests stop at older versions).
          if (details.versionNow == schemaVersion) await seedSystemData(this);
        },
      );
}
