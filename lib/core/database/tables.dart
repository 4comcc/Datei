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

  /// v2: false when only day and month are known (the stored year is then a
  /// leap-year placeholder, 2000, and must never be shown or used for age).
  BoolColumn get birthYearKnown => boolean().withDefault(const Constant(true))();

  /// male | female | null (not specified).
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

/// v2. Directed: (person_id IS relation_type OF related_person_id).
/// related_person_id NULL means the relation is to the device owner ("my father").
@DataClassName('PersonRelationshipRow')
@TableIndex(name: 'idx_rel_person', columns: {#personId})
@TableIndex(name: 'idx_rel_related', columns: {#relatedPersonId})
class PersonRelationships extends Table with Timestamps {
  TextColumn get id => text()();
  TextColumn get personId => text().references(Persons, #id, onDelete: KeyAction.cascade)();
  TextColumn get relatedPersonId => text().nullable().references(Persons, #id, onDelete: KeyAction.cascade)();

  /// father | mother | son | daughter | brother | sister | spouse | relative | friend | colleague | custom
  TextColumn get relationType => text()();
  TextColumn get customLabel => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK (related_person_id IS NULL OR related_person_id <> person_id)',
        "CHECK (relation_type <> 'custom' OR (custom_label IS NOT NULL AND length(trim(custom_label)) > 0))",
      ];
}

/// v2. User-defined extra fields for people.
@DataClassName('CustomFieldDefinitionRow')
class CustomFieldDefinitions extends Table with Timestamps {
  TextColumn get id => text()();

  /// 'person' (more entity types later).
  TextColumn get entityType => text().withDefault(const Constant('person'))();
  TextColumn get label => text().withLength(min: 1, max: 80)();

  /// text | number | date | url
  TextColumn get fieldType => text().withDefault(const Constant('text'))();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('CustomFieldValueRow')
class CustomFieldValues extends Table {
  TextColumn get definitionId => text().references(CustomFieldDefinitions, #id, onDelete: KeyAction.cascade)();
  TextColumn get entityId => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {definitionId, entityId};
}

/// v2. Named filters; `definition` is a versioned JSON document.
@DataClassName('SavedFilterRow')
class SavedFilters extends Table with Timestamps {
  TextColumn get id => text()();

  /// people | events | commitments | global
  TextColumn get scope => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get definition => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

/// v3. Per-occurrence changes to a recurring event: a cancelled occurrence or an
/// override (JSON of changed fields: title, date, time, endTime, location, notes).
@DataClassName('EventExceptionRow')
@TableIndex(name: 'idx_event_exceptions_event', columns: {#eventId})
class EventExceptions extends Table with Timestamps {
  TextColumn get id => text()();
  TextColumn get eventId => text().references(Events, #id, onDelete: KeyAction.cascade)();

  /// The occurrence's original date in the series ('YYYY-MM-DD').
  TextColumn get originalDate => text()();

  /// cancelled | overridden
  TextColumn get kind => text()();
  TextColumn get overrideJson => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {eventId, originalDate},
      ];
}

/// v4. Built-in (system_key) and user commitment types.
@DataClassName('CommitmentTypeRow')
class CommitmentTypes extends Table with Timestamps {
  TextColumn get id => text()();
  TextColumn get systemKey => text().nullable().unique()();
  TextColumn get name => text().nullable()();
  IntColumn get color => integer().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isSystem => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

/// v4. Commitments and renewals (domains, subscriptions, IDs, insurance…).
@DataClassName('CommitmentRow')
@TableIndex(name: 'idx_commitments_expiry', columns: {#expiryDate})
@TableIndex(name: 'idx_commitments_deleted_at', columns: {#deletedAt})
class Commitments extends Table with Timestamps, Syncable {
  TextColumn get id => text()();
  TextColumn get ownerProfileId => text().references(LocalUserProfiles, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get commitmentTypeId => text().references(CommitmentTypes, #id, onDelete: KeyAction.restrict)();
  TextColumn get providerName => text().nullable()();
  TextColumn get startDate => text().nullable()();

  /// Expiry / due date ('YYYY-MM-DD').
  TextColumn get expiryDate => text()();

  /// Optional date by which to renew (reminders anchor here when set).
  TextColumn get renewalDate => text().nullable()();

  /// Money in minor units (e.g. piastres/cents) + ISO 4217 code (ADR-020).
  IntColumn get amountMinor => integer().nullable()();
  TextColumn get currency => text().nullable().withLength(min: 3, max: 3)();

  /// Renewal period in months (null = no fixed period).
  IntColumn get renewalMonths => integer().nullable()();
  TextColumn get referenceNumber => text().nullable()();
  TextColumn get serviceUrl => text().nullable()();
  TextColumn get notes => text().nullable()();

  /// active | completed | cancelled (time-based states are computed).
  TextColumn get lifecycleStatus => text().withDefault(const Constant('active'))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => [
        'CHECK (renewal_months IS NULL OR renewal_months >= 1)',
        'CHECK (amount_minor IS NULL OR amount_minor >= 0)',
      ];
}

/// v4. History of renewals.
@DataClassName('CommitmentRenewalRow')
@TableIndex(name: 'idx_renewals_commitment', columns: {#commitmentId})
class CommitmentRenewals extends Table {
  TextColumn get id => text()();
  TextColumn get commitmentId => text().references(Commitments, #id, onDelete: KeyAction.cascade)();
  IntColumn get renewedAt => integer()();
  TextColumn get previousExpiryDate => text()();
  TextColumn get newExpiryDate => text()();
  IntColumn get amountMinor => integer().nullable()();
  TextColumn get currency => text().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// v4. Reminder offsets for events and commitments (minutes before the anchor;
/// days are multiples of 1440). Owner integrity is kept by the repositories.
@DataClassName('ReminderRow')
@TableIndex(name: 'idx_reminders_owner', columns: {#ownerType, #ownerId})
class Reminders extends Table with Timestamps {
  TextColumn get id => text()();

  /// event | commitment
  TextColumn get ownerType => text()();
  TextColumn get ownerId => text()();
  IntColumn get offsetMinutes => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {ownerType, ownerId, offsetMinutes},
      ];

  @override
  List<String> get customConstraints => ['CHECK (offset_minutes >= 0)'];
}

/// v5. Free-form tags shared by memories (and later other entities).
@DataClassName('TagRow')
class Tags extends Table with Timestamps {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60).unique()();
  IntColumn get color => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// v5. Tag links (polymorphic; owners are cleaned by repositories).
@DataClassName('EntityTagRow')
@TableIndex(name: 'idx_entity_tags_entity', columns: {#entityType, #entityId})
class EntityTagRelations extends Table {
  TextColumn get tagId => text().references(Tags, #id, onDelete: KeyAction.cascade)();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();

  @override
  Set<Column> get primaryKey => {tagId, entityType, entityId};
}

/// v5.
@DataClassName('MemoryRow')
@TableIndex(name: 'idx_memories_date', columns: {#memoryDate})
class Memories extends Table with Timestamps, Syncable {
  TextColumn get id => text()();
  TextColumn get ownerProfileId => text().references(LocalUserProfiles, #id)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get body => text().nullable()();
  TextColumn get memoryDate => text()();
  TextColumn get eventId => text().nullable().references(Events, #id, onDelete: KeyAction.setNull)();
  TextColumn get category => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MemoryPersonRow')
@TableIndex(name: 'idx_mpr_person', columns: {#personId})
class MemoryPersonRelations extends Table {
  TextColumn get memoryId => text().references(Memories, #id, onDelete: KeyAction.cascade)();
  TextColumn get personId => text().references(Persons, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {memoryId, personId};
}

/// v5. Light projects and personal goals.
@DataClassName('ProjectRow')
class Projects extends Table with Timestamps, Syncable {
  TextColumn get id => text()();
  TextColumn get ownerProfileId => text().references(LocalUserProfiles, #id)();
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get startDate => text().nullable()();
  TextColumn get dueDate => text().nullable()();

  /// planned | active | onHold | done | cancelled
  TextColumn get status => text().withDefault(const Constant('planned'))();

  /// low | normal | high | critical
  TextColumn get priority => text().withDefault(const Constant('normal'))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<String> get customConstraints => ['CHECK (due_date IS NULL OR start_date IS NULL OR due_date >= start_date)'];
}

@DataClassName('ProjectPersonRow')
class ProjectPersonRelations extends Table {
  TextColumn get projectId => text().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get personId => text().references(Persons, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {projectId, personId};
}

@DataClassName('ProjectEventRow')
class ProjectEventRelations extends Table {
  TextColumn get projectId => text().references(Projects, #id, onDelete: KeyAction.cascade)();
  TextColumn get eventId => text().references(Events, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {projectId, eventId};
}

/// v5. Life milestones.
@DataClassName('MilestoneRow')
@TableIndex(name: 'idx_milestones_date', columns: {#milestoneDate})
class Milestones extends Table with Timestamps, Syncable {
  TextColumn get id => text()();
  TextColumn get ownerProfileId => text().references(LocalUserProfiles, #id)();
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get milestoneDate => text()();

  /// firstSchoolDay | graduation | firstJob | marriage | newHome | achievement | projectStart | goalReached | custom
  TextColumn get kind => text().withDefault(const Constant('custom'))();
  TextColumn get personId => text().nullable().references(Persons, #id, onDelete: KeyAction.setNull)();
  TextColumn get projectId => text().nullable().references(Projects, #id, onDelete: KeyAction.setNull)();
  TextColumn get eventId => text().nullable().references(Events, #id, onDelete: KeyAction.setNull)();

  @override
  Set<Column> get primaryKey => {id};
}

/// v5. Files stored under the app's documents directory (relative paths).
@DataClassName('AttachmentRow')
@TableIndex(name: 'idx_attachments_owner', columns: {#ownerType, #ownerId})
class Attachments extends Table {
  TextColumn get id => text()();

  /// memory (more owners later)
  TextColumn get ownerType => text()();
  TextColumn get ownerId => text()();
  TextColumn get relativePath => text()();
  TextColumn get mimeType => text()();
  IntColumn get sizeBytes => integer()();
  TextColumn get originalName => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}
