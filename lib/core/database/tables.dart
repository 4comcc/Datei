// Drift table definitions — schema v1. See docs/DATABASE_SCHEMA.md.
//
// Conventions: UUID text primary keys; created_at/updated_at as UTC epoch ms;
// civil dates as 'YYYY-MM-DD' text; soft delete via deleted_at on syncable
// entities; row_version for future sync.
import 'package:drift/drift.dart';

mixin Timestamps on Table {
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
}

mixin Syncable on Table {
  IntColumn get deletedAt => integer().nullable()();
  IntColumn get rowVersion => integer().withDefault(const Constant(1))();
}

@DataClassName('LocalUserProfileRow')
class LocalUserProfiles extends Table with Timestamps {
  TextColumn get id => text()();
  TextColumn get displayName => text().nullable()();

  /// 'guest' until bound to an authenticated account.
  TextColumn get state => text().withDefault(const Constant('guest'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AccountMetadataRow')
class AccountMetadata extends Table with Timestamps {
  TextColumn get id => text()();
  TextColumn get profileId => text().references(LocalUserProfiles, #id, onDelete: KeyAction.cascade)();
  TextColumn get authUid => text().unique()();

  /// JSON array of provider ids, e.g. ["google.com"]. Never tokens or passwords.
  TextColumn get providers => text().withDefault(const Constant('[]'))();
  TextColumn get email => text().nullable()();
  TextColumn get displayName => text().nullable()();
  TextColumn get photoUrl => text().nullable()();
  IntColumn get lastSignInAt => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('AppSettingRow')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {key};
}

@DataClassName('PersonRow')
@TableIndex(name: 'idx_persons_full_name', columns: {#fullName})
@TableIndex(name: 'idx_persons_birth_date', columns: {#birthDate})
@TableIndex(name: 'idx_persons_deleted_at', columns: {#deletedAt})
class Persons extends Table with Timestamps, Syncable {
  TextColumn get id => text()();
  TextColumn get ownerProfileId => text().references(LocalUserProfiles, #id)();
  TextColumn get fullName => text().withLength(min: 1, max: 200)();
  TextColumn get displayName => text().nullable()();
  TextColumn get birthDate => text().nullable()();
  TextColumn get gender => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get occupation => text().nullable()();
  TextColumn get organization => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PersonCategoryRow')
class PersonCategories extends Table with Timestamps {
  TextColumn get id => text()();

  /// Stable key for built-in categories (localized via ARB); null for user-created ones.
  TextColumn get systemKey => text().nullable().unique()();
  TextColumn get name => text().nullable()();
  IntColumn get color => integer().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PersonCategoryRelationRow')
@TableIndex(name: 'idx_pcr_category', columns: {#categoryId})
class PersonCategoryRelations extends Table {
  TextColumn get personId => text().references(Persons, #id, onDelete: KeyAction.cascade)();
  TextColumn get categoryId => text().references(PersonCategories, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {personId, categoryId};
}

@DataClassName('EventTypeRow')
class EventTypes extends Table with Timestamps {
  TextColumn get id => text()();
  TextColumn get systemKey => text().nullable().unique()();
  TextColumn get name => text().nullable()();
  TextColumn get icon => text().nullable()();
  IntColumn get color => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('RecurrenceRuleRow')
class RecurrenceRules extends Table with Timestamps {
  TextColumn get id => text()();

  /// daily | weekly | monthly | yearly
  TextColumn get freq => text()();
  IntColumn get interval => integer().withDefault(const Constant(1))();
  TextColumn get byWeekday => text().nullable()();
  IntColumn get byMonthDay => integer().nullable()();
  IntColumn get byMonth => integer().nullable()();
  IntColumn get bySetPos => integer().nullable()();
  TextColumn get untilDate => text().nullable()();
  IntColumn get count => integer().nullable()();

  /// skip | clamp_to_last_day
  TextColumn get overflowPolicy => text().withDefault(const Constant('clamp_to_last_day'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK ("interval" >= 1)',
        'CHECK (NOT (until_date IS NOT NULL AND count IS NOT NULL))',
      ];
}

@DataClassName('EventRow')
@TableIndex(name: 'idx_events_start_date', columns: {#startDate})
@TableIndex(name: 'idx_events_type', columns: {#eventTypeId})
@TableIndex(name: 'idx_events_deleted_at', columns: {#deletedAt})
class Events extends Table with Timestamps, Syncable {
  TextColumn get id => text()();
  TextColumn get ownerProfileId => text().references(LocalUserProfiles, #id)();
  TextColumn get title => text().withLength(min: 1, max: 300)();
  TextColumn get description => text().nullable()();
  TextColumn get eventTypeId => text().references(EventTypes, #id, onDelete: KeyAction.restrict)();
  TextColumn get startDate => text()();
  TextColumn get startTime => text().nullable()();
  TextColumn get endDate => text().nullable()();
  TextColumn get endTime => text().nullable()();
  BoolColumn get allDay => boolean().withDefault(const Constant(true))();
  TextColumn get tzId => text().nullable()();
  TextColumn get location => text().nullable()();

  /// low | normal | high | critical
  TextColumn get priority => text().withDefault(const Constant('normal'))();
  IntColumn get color => integer().nullable()();

  /// planned | done | cancelled
  TextColumn get status => text().withDefault(const Constant('planned'))();
  TextColumn get recurrenceRuleId =>
      text().nullable().references(RecurrenceRules, #id, onDelete: KeyAction.setNull)();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (end_date IS NULL OR end_date >= start_date)'];
}

@DataClassName('EventPersonRelationRow')
@TableIndex(name: 'idx_epr_person', columns: {#personId})
class EventPersonRelations extends Table {
  TextColumn get eventId => text().references(Events, #id, onDelete: KeyAction.cascade)();
  TextColumn get personId => text().references(Persons, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text().nullable()();

  @override
  Set<Column> get primaryKey => {eventId, personId};
}
