import 'package:drift/drift.dart';

import 'app_database.dart';

/// Stable ids for built-in rows: `sys:<kind>:<key>`. Inserted idempotently on every open.
String systemCategoryId(String key) => 'sys:category:$key';
String systemEventTypeId(String key) => 'sys:event_type:$key';
String systemCommitmentTypeId(String key) => 'sys:commitment_type:$key';

const systemCommitmentTypeKeys = [
  'domain',
  'hosting',
  'ssl',
  'contract',
  'license',
  'insurance',
  'warranty',
  'subscription',
  'bill',
  'payment',
  'installment',
  'passport',
  'national_id',
  'vehicle_license',
  'other',
];

const systemCategoryKeys = ['family', 'relatives', 'friends', 'colleagues', 'clients', 'other'];
const systemEventTypeKeys = [
  'anniversary',
  'appointment',
  'travel',
  'graduation',
  'achievement',
  'family',
  'religious',
  'personal',
  'other',
];

Future<void> seedSystemData(AppDatabase db) async {
  final now = DateTime.now().toUtc().millisecondsSinceEpoch;
  await db.batch((b) {
    for (final (i, key) in systemCategoryKeys.indexed) {
      b.insert(
        db.personCategories,
        PersonCategoriesCompanion.insert(
          id: systemCategoryId(key),
          systemKey: Value(key),
          isSystem: const Value(true),
          sortOrder: Value(i),
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
    for (final (i, key) in systemEventTypeKeys.indexed) {
      b.insert(
        db.eventTypes,
        EventTypesCompanion.insert(
          id: systemEventTypeId(key),
          systemKey: Value(key),
          isSystem: const Value(true),
          sortOrder: Value(i),
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
    for (final (i, key) in systemCommitmentTypeKeys.indexed) {
      b.insert(
        db.commitmentTypes,
        CommitmentTypesCompanion.insert(
          id: systemCommitmentTypeId(key),
          systemKey: Value(key),
          isSystem: const Value(true),
          sortOrder: Value(i),
          createdAt: now,
          updatedAt: now,
        ),
        mode: InsertMode.insertOrIgnore,
      );
    }
  });
}
