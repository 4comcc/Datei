# Datei — Database Schema (Drift / SQLite)

Status: **schema v2 implemented** (v1 Phase 1; v2 Phase 4 adds persons.birth_year_known, person_relationships, custom_field_definitions, custom_field_values, saved_filters). Previously: **schema v1 implemented** (Phase 1, `lib/core/database/tables.dart`): local_user_profiles, account_metadata, app_settings, persons, person_categories, person_category_relations, event_types, recurrence_rules, events, event_person_relations. Remaining tables are added in their phase with a schema bump and migration test.
Every schema change bumps `schemaVersion`, adds a step migration, and stores a schema dump
(`drift_schemas/drift_schema_vN.json`) for migration tests.

## Conventions
- PK `id TEXT` = UUID (v7 preferred: time-ordered, sync-friendly). Lookup/system tables may use stable string keys.
- `created_at`, `updated_at` INTEGER (UTC epoch ms) on every user table; `deleted_at` INTEGER NULL (soft delete) on syncable entities; `row_version INTEGER NOT NULL DEFAULT 1`.
- Civil dates `TEXT 'YYYY-MM-DD'`; times `TEXT 'HH:mm'`; `tz_id TEXT` (IANA). Instants as epoch ms UTC.
- Enums stored as TEXT keys (stable across reorderings).
- `PRAGMA foreign_keys = ON`; join tables `ON DELETE CASCADE`; references to optional parents `ON DELETE SET NULL`.
- Built-in types/categories have `is_system = 1` and a `system_key`; display names come from ARB by key (so they translate). User-created ones store `name`.
- Multi-step operations (save event + people + reminders + recurrence) run inside `transaction()`.
- Full-text search: FTS5 virtual table `search_index` (entity_type, entity_id, title, body, tags) maintained by repository code / triggers.

## Identity & settings
| Table | Key columns |
|---|---|
| `local_user_profile` | id, display_name, state (`guest`/`bound`), created_at, updated_at — exactly one active row |
| `account_metadata` | id, profile_id → local_user_profile, auth_uid (UNIQUE), providers (JSON list), email, display_name, photo_url, last_sign_in_at, created_at, updated_at. **No tokens/passwords.** |
| `app_settings` | key TEXT PK, value TEXT (JSON), updated_at (language, theme, Hijri on/offset, home layout, reminder defaults…) |

Secrets (PIN hash/salt, backup key material) live in flutter_secure_storage, **not** in SQLite.

## People
| Table | Columns / constraints |
|---|---|
| `persons` | id, owner_profile_id, full_name NOT NULL, display_name, photo_attachment_id → attachments (SET NULL), birth_date TEXT NULL, birth_year_known BOOL DEFAULT 1, gender TEXT NULL, phone, email, address, occupation, organization, notes, timestamps, deleted_at. Indexes: (full_name), (display_name), (birth month-day expression `substr(birth_date,6,5)`), (occupation), (organization) |
| `person_categories` | id, system_key UNIQUE NULL, name, color, icon, sort_order, is_system, timestamps |
| `person_category_relations` | person_id → persons CASCADE, category_id → person_categories CASCADE, PK(person_id, category_id) |
| `person_relationships` | id, person_id → persons CASCADE, related_person_id → persons CASCADE NULL (or free-text target for "user"), relation_type (father/mother/son/daughter/brother/sister/spouse/relative/friend/colleague/custom), custom_label, notes, timestamps. Directed: A→B does **not** imply B→A. UNIQUE(person_id, related_person_id, relation_type, custom_label) |
| `custom_field_definitions` | id, entity_type ('person'), key, label, field_type (text/number/date/url/bool), sort_order, timestamps |
| `custom_field_values` | id, definition_id → CASCADE, entity_id, value TEXT, UNIQUE(definition_id, entity_id) |

## Events & recurrence
| Table | Columns / constraints |
|---|---|
| `event_types` | id, system_key UNIQUE NULL (birthday, wedding_anniversary, marriage, graduation, job_start, job_change, travel, appointment, achievement, family_event, religious_occasion, personal_event, memorial, custom), name, icon, color, is_system |
| `events` | id, owner_profile_id, title NOT NULL, description, event_type_id → event_types (RESTRICT), start_date NOT NULL, start_time NULL, end_date NULL, end_time NULL, all_day BOOL, tz_id, location, category_id NULL, priority (low/normal/high/critical), color, status (planned/done/cancelled), recurrence_rule_id → recurrence_rules NULL, notes, source ('user' / 'person_birthday'), timestamps, deleted_at. CHECK(end_date IS NULL OR end_date >= start_date). Indexes: (start_date), (event_type_id), (status), (recurrence_rule_id) |
| `event_person_relations` | event_id CASCADE, person_id CASCADE, role TEXT NULL, PK(event_id, person_id) |
| `recurrence_rules` | id, freq (daily/weekly/monthly/yearly), interval ≥1, by_weekday (CSV), by_month_day, by_month, by_set_pos, until_date NULL, count NULL, overflow_policy (skip/clamp_to_last_day), timestamps. CHECK(NOT (until_date IS NOT NULL AND count IS NOT NULL)) |
| `recurrence_exceptions` | id, rule_owner_type ('event'/'commitment'), owner_id, original_date NOT NULL, kind (cancelled/overridden), override_json NULL, UNIQUE(owner_type, owner_id, original_date) |

Birthdays: **derived** from `persons.birth_date` by the time engine (no duplicated event rows). Optional user events of type birthday may still be created for non-persons.

## Commitments
| Table | Columns / constraints |
|---|---|
| `commitment_types` | id, system_key UNIQUE NULL (domain, hosting, ssl, contract, license, insurance, warranty, subscription, bill, payment, installment, passport, national_id, vehicle_license, custom), name, icon, is_system |
| `commitments` | id, owner_profile_id, name NOT NULL, commitment_type_id → RESTRICT, provider_name, start_date, expiry_date, renewal_date, amount_minor INTEGER NULL (money in minor units), currency TEXT(3), recurrence_rule_id NULL, reference_number, service_url, notes, lifecycle_status (active/renewed/completed/cancelled), timestamps, deleted_at. Computed (not stored) display status: Upcoming / Due soon / Overdue derived from dates + lifecycle. Indexes: (expiry_date), (renewal_date), (lifecycle_status) |
| `commitment_renewals` | id, commitment_id CASCADE, renewed_at, previous_expiry_date, new_expiry_date, amount_minor, currency, notes, created_at |
| `commitment_person_relations` | commitment_id CASCADE, person_id CASCADE, PK |

## Memories, milestones, projects
| Table | Columns |
|---|---|
| `memories` | id, owner_profile_id, title NOT NULL, body, memory_date NOT NULL, event_id → events SET NULL, category, timestamps, deleted_at; index (memory_date) |
| `memory_person_relations` | memory_id CASCADE, person_id CASCADE, PK |
| `milestones` | id, owner_profile_id, title NOT NULL, description, milestone_date NOT NULL, kind (first_school_day/graduation/first_job/marriage/new_home/achievement/project_start/goal_reached/custom), person_id SET NULL, project_id SET NULL, event_id SET NULL, timestamps, deleted_at |
| `projects` | id, owner_profile_id, name NOT NULL, description, start_date, due_date, status (planned/active/on_hold/done/cancelled), priority, notes, timestamps, deleted_at |
| `project_person_relations`, `project_event_relations` | join tables, CASCADE |

## Cross-cutting
| Table | Columns |
|---|---|
| `reminders` | id, owner_type (event/commitment/project/person_birthday/memory_anniversary), owner_id, offset_minutes INTEGER (≥0, minutes before due; days = ×1440), at_time TEXT NULL (time of day for all-day items), enabled, timestamps. Index (owner_type, owner_id) |
| `scheduled_notifications` | notification_id INTEGER PK, reminder_id → reminders CASCADE, owner_type, owner_id, occurrence_date, fire_at_utc, created_at |
| `attachments` | id, owner_type, owner_id, kind (image/file), relative_path (under app documents dir), mime_type, size_bytes, sha256, original_name, timestamps |
| `tags` | id, name UNIQUE COLLATE NOCASE, color, timestamps |
| `entity_tag_relations` | tag_id CASCADE, entity_type, entity_id, PK(tag_id, entity_type, entity_id) |
| `saved_filters` | id, scope (people/events/commitments/global), name, definition_json (versioned filter AST with AND/OR groups), sort_order, timestamps |
| `search_index` | FTS5(entity_type UNINDEXED, entity_id UNINDEXED, title, body, tags) |

Polymorphic tables (`reminders`, `attachments`, `entity_tag_relations`) can't use SQL FKs to multiple parents; integrity is enforced in repositories (deletion of an owner deletes its reminders/attachments/tags in the same transaction) and covered by tests.

## Migrations policy
- `MigrationStrategy.onUpgrade` with drift `stepByStep` generated helpers.
- Each version: schema dump committed + test `verifier.migrateAndValidate(db, N)`.
- Seed system types/categories in `onCreate` and idempotently in `beforeOpen` (insert-or-ignore by `system_key`).
- Backup files carry `schemaVersion`; importer upgrades older payloads via mapping functions.
