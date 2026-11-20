# Architecture Decision Records — Datei

Format: ID · Status · Decision · Rationale · Alternatives. Status: Accepted / Proposed (needs owner input) / Superseded.

**ADR-001 · Accepted · Flutter stable 3.50.0 / Dart 3.14.0.** Latest stable on 2026-11-19. All packages selected are compatible (`sdk ^3.12` max requirement).

**ADR-002 · Accepted · Clean Architecture + feature-first + Riverpod 3 (codegen) + GoRouter.** As requested; Riverpod providers double as DI container and make test overrides trivial.

**ADR-003 · Accepted · Drift on SQLite, local-first.** Type-safe queries, reactive streams, migration tooling with schema verification. `sqlite3_flutter_libs` is end-of-life (2026); use drift_flutter with the `sqlite3` package's bundled native build.

**ADR-004 · Accepted · UUID text primary keys + timestamps + soft delete + row_version.** Prepares for multi-device sync without schema rewrite. Cost: slightly larger indexes — negligible at personal-data scale.

**ADR-005 · Accepted · Civil dates as `YYYY-MM-DD`, times as `HH:mm` + IANA tz; instants as UTC ms.** Birthdays/anniversaries are not instants; storing them as UTC DateTime causes off-by-one bugs across timezones/DST.

**ADR-006 · Accepted · Recurrence stored as rule + exceptions; occurrences computed.** Per requirement; avoids unbounded rows; supports this / following / all edit scopes.

**ADR-007 · Accepted · Birthdays derived from persons.birth_date, not duplicated as events.** Single source of truth; changing the birth date updates calendar, home, reminders automatically.

**ADR-008 · Accepted · Birth year optional.** Many people know a birthday but not the year; age is hidden in that case.

**ADR-009 · Accepted (configurable) · Feb 29 birthdays observed on Feb 28 in non-leap years by default**, user may choose Mar 1. Age increments on the observed day. Documented and unit-tested.

**ADR-010 · Accepted · Guest mode without Firebase anonymous auth.** Guest works fully offline and needs no network. Local data belongs to `local_user_profile`; signing in *binds* the profile to the Firebase uid — no data copy, so no loss/duplication. Alternative (Firebase anonymous + linkWithCredential) adds network dependency on first run and gives no benefit until cloud sync exists; can be introduced with sync later.

**ADR-011 · Accepted · Sign-in ≠ sync.** v1 never uploads user data. Future sync is a separate opt-in module.

**ADR-012 · Accepted · Auth gracefully degrades when Firebase isn't configured.** Firebase config files are git-ignored; a build without them runs guest-only and shows "sign-in unavailable in this build". No dummy keys.

**ADR-013 · Accepted · Google Sign-In via google_sign_in v7 (Android Credential Manager) → Firebase credential.** v7 is the maintained API (`initialize`/`authenticate`); requires the Web client ID as `serverClientId`.

**ADR-014 · Accepted · Facebook via flutter_facebook_auth, permissions `public_profile` + `email` only.** No friends/contacts. Requires Facebook Login use-case review only for non-default permissions (none requested).

**ADR-015 · Accepted · Firebase "One account per email address" + explicit linking flow.** Prevents duplicate accounts; on collision, user signs in with existing provider then the pending credential is linked.

**ADR-016 · Accepted · Hijri via `hijri` package (Umm al-Qura) behind an interface + user offset (−2…+2 days).** Gregorian remains the stored truth; Hijri for display/input; UI explains that local moon-sighting may differ. Package accuracy range to be verified in Phase 5 tests; fallback: own Umm al-Qura table implementation.

**ADR-017 · Accepted · Notifications: rolling window (60 days / ≤300) + replanning; inexact by default, exact alarms opt-in.** Android alarm limits and Play policy on `USE_EXACT_ALARM` (restricted to alarm/calendar core apps); use `SCHEDULE_EXACT_ALARM` with user grant instead.

**ADR-018 · Accepted · Bundled fonts: IBM Plex Sans Arabic + IBM Plex Sans (SIL OFL 1.1).** Harmonised Arabic/Latin design, licence permits bundling; no runtime font download (offline + privacy). Cairo is an acceptable alternative (also OFL).

**ADR-019 · Accepted · Backup format: zip (`.datei`) with manifest + JSON + attachments; optional AES-256-GCM with Argon2id KDF (package `cryptography`).** Self-describing, verifiable (SHA-256 per entry), versioned.

**ADR-020 · Accepted · Money stored as integer minor units + ISO currency.** Avoids floating-point errors.

**ADR-021 · Accepted (2026-11-19, owner) · Android applicationId and namespace `com.fourcom.datei`.** Permanent once uploaded to Google Play.

**ADR-022 · Proposed · Calendar UI: custom-built month/week/day views** (instead of `table_calendar`, which lacks week/day timelines and Hijri sub-labels). Final call in Phase 5.

**ADR-023 · Proposed · Sync conflict policy (future):** per-field last-writer-wins using `updated_at` + `row_version`, tombstones for deletes; revisit when sync is designed.

**ADR-024 · Accepted · No analytics/crash-reporting SDK in v1.** Simplifies Data safety declaration; may be added later as opt-in.

**ADR-025 · Accepted · Flutter 3.50 split libraries: import `package:material_ui/material_ui.dart` (and `cupertino_ui`), not `package:flutter/material.dart`.** `GlobalMaterialLocalizations`/`GlobalCupertinoLocalizations` now come from those packages; `flutter_localizations` is used only for `GlobalWidgetsLocalizations`.

**ADR-026 · Accepted (prototype only) · Prototype v0.1 stores data as JSON in SharedPreferences behind `LocalStore`.** Fast to ship for UX validation; replaced by Drift in Phase 1. The time engine, agenda service, theme, l10n and screens are kept and evolved, not thrown away.

**ADR-027 · Accepted · Fonts converted from IBM's official npm package `@ibm/plex-sans-arabic` 1.1.0 (WOFF2 → TTF via fontTools)** because Flutter cannot load WOFF; licence file shipped in `assets/fonts/`.

**ADR-028 · Accepted (revisit) · Latin digits in both languages for v0.1.** intl renders Arabic dates with Arabic-Indic digits but numbers with Latin, producing mixed text. Unified to Latin; add a Settings option "Arabic-Indic digits" that switches both dates and numbers consistently.

**ADR-029 · Accepted · Settings live in the `app_settings` table, loaded before `runApp`.** The router needs language/onboarding synchronously; bootstrap reads all settings once and `SettingsController` writes through the repository. SharedPreferences is now used only to read prototype data during the one-time import.

**ADR-030 · Accepted · One-time prototype import (`LegacyPrototypeImporter`).** Imports v0.1 JSON (people, events, settings) inside a single transaction; old keys are removed only after commit, so a failure never loses data. Corrupt JSON is skipped rather than blocking startup. Note: the prototype APK used applicationId `app.datei.prototype`; the Phase 1 build is a different Android app (`com.fourcom.datei`), so data from the installed prototype is not reachable by it. The importer covers upgrades of builds that share the final id.

**ADR-031 · Accepted · Soft delete semantics (v1).** Deleting a person sets `deleted_at` and removes their event links in the same transaction; deleting an event sets `deleted_at`. Queries exclude soft-deleted rows. "Erase all data" hard-deletes user rows and keeps settings, profile and system types. A trash/restore UI may come later.

**ADR-032 · Accepted · Riverpod without code generation and no Freezed for now.** Manual providers keep the build simple while models are few; revisit when models grow (Phase 4+). Drift code generation is used (`build_runner`); generated `*.g.dart` files are committed so the project builds without running the generator first.

**ADR-033 · Accepted · Built-in categories/event types have stable ids `sys:<kind>:<key>`** and are seeded idempotently on every open (insert-or-ignore). Labels come from ARB by `system_key`.

**ADR-034 · Deferred to Phase 5 · `tz_id` on timed events.** Phase 1 stores local wall time (`start_time`) with `tz_id` null; capturing the device IANA zone needs `flutter_timezone`, added with notifications/recurrence work.

**ADR-035 · Accepted (temporary) · v0.2 hung on the splash screen on a real device; startup hardened and dependencies pinned.** Root cause not observable here (no device/emulator). v0.1 (working) did not use path_provider; v0.2 added it via Drift, resolving `path_provider_android` 2.3.1 (jni/jni_flutter based) and the publisher-retracted `jni` 1.2.0. Changes: (1) `dependency_overrides` pin `path_provider_android: 2.2.23` (last Pigeon-based release) and `jni: 1.1.2` (latest non-retracted); (2) `main()` now draws the first frame immediately and opens data behind `StartupApp`, which shows a localized error screen with copyable details and Retry on failure or after a 20 s timeout. Remove the pins once the device test passes on current versions.

**ADR-035 update (2026-11-19):** v0.2.1 confirmed by the owner to start normally on their Android phone. Pins stay until a later build verifies current upstream versions on device.

**ADR-036 · Accepted (owner, 2026-11-19) · App icon direction A "Geometric D".** Three directions were explored (A geometric D, B D + calendar page, C arc of time; `assets/branding/concepts/`). A was chosen: strongest legibility at 48 px, no heart or stock calendar imagery. The adaptive/monochrome/splash layers scale the mark to 86 % to stay inside the 66 dp safe circle.

**ADR-037 · Accepted · Splash and launcher assets configured by hand, rendered from SVG with `tool/render_branding.js` (Playwright).** No `flutter_launcher_icons`/`flutter_native_splash` dependency: Android 12+ uses `windowSplashScreen*` (light/dark), older versions a layer-list with the rounded icon; Android 13 themed icons via the `monochrome` layer. SVG sources in `assets/branding/` are the single source of truth.

**ADR-038 · Accepted · Birth year optional via `persons.birth_year_known`.** When false, `birth_date` stores the leap-year placeholder 2000 (keeps Feb 29 valid); domain exposes `birthDateWithYear` (null) so age, "turns N", age filters and birth-year filters never use the placeholder.

**ADR-039 · Accepted · Relationships are directed rows `(person IS type OF related)`; `related_person_id` NULL = "of me".** Never mirrored automatically (PRD). Profiles show outgoing ("Sister of Sara", "Father (to you)") and incoming ("Ahmad — Father") rows. Self-relations and unlabeled custom relations are rejected by both repository validation and CHECK constraints.

**ADR-040 · Accepted · People categories referenced by id.** Built-in ids `sys:category:<key>` (localized), user categories UUID with name/colour. Deleting a user category cascades its links only.

**ADR-041 · Accepted · Custom fields: definitions + per-person values (text/number/date/url), validated in the form, saved with the person in one transaction.** Values for deleted definitions cascade away. Erase-all keeps definitions (configuration).

**ADR-042 · Accepted · People filter is a pure domain object (`PeopleFilter.matches`) combining criteria with AND (categories: any-of).** Saved filters store versioned JSON (`v: 1`) without the free-text query. Filter state lives in a Riverpod notifier, not in widgets.

**ADR-043 · Accepted · Schema v2 migration via drift `stepByStep`, verified by the generated schema test plus a data-preservation test.** The verifier caught missing index creation during development.

**ADR-044 · Accepted · Recurrence engine (`lib/core/recurrence_engine`): daily / weekly (weekday set) / monthly (day-of-month with clamp-or-skip, or nth/last weekday) / yearly (Feb-29 policy), interval, until | count.** Occurrences are generated lazily; uncounted series jump near the requested window instead of iterating from the start. Excluded dates still consume `count` (RFC 5545 EXDATE semantics).

**ADR-045 · Accepted · Per-occurrence exceptions in `event_exceptions` (schema v3): cancelled or overridden (JSON: title, date, time, clearTime, location, notes); unique per (event, original date).** Edit scopes: *this* → exception; *this and following* → `SeriesEditing.split` ends the old series the day before (until) and starts a new one, carrying the remaining `count` when the rule is unchanged, dropping later exceptions; *all* → whole-series save, shifting the series start by the same number of days the shown occurrence was moved.

**ADR-046 · Accepted · Hijri via `hijri` 3.0.1 (Umm al-Qura table 1356–1500 AH) wrapped in `HijriConverter` with a user offset of −2…+2 days.** Verified against known Umm al-Qura month starts and a two-year day-by-day round trip. Month names come from our ARB files (the package's global locale is not used). Display/input only; Gregorian stays stored.

**ADR-047 · Accepted · Custom event types share the categories pattern (`sys:event_type:<key>` + user types).** Deleting a user type moves its events to "Other"; unknown type ids fall back to "Other" on save.

**ADR-048 · Accepted · Multi-day events store `end_date`; every occurrence spans the same number of days.** The agenda marks each covered day; ongoing events count as "today" and as the next occurrence.

**ADR-049 · Accepted · Screens closed after save/delete use `popOrGo(fallback)`.** Safe when a screen is opened directly (future notification deep links) — found by widget tests.

**ADR-050 · Accepted · Local notifications with `flutter_local_notifications` 23.0.3 + `timezone` + `flutter_timezone`.** Requires compileSdk 37 (`platforms;android-37.0`), core-library desugaring, `RECEIVE_BOOT_COMPLETED` and the plugin's scheduled/boot receivers. A monochrome vector status icon (`ic_stat_datei`) is kept from resource shrinking via `res/raw/keep.xml`. `SCHEDULE_EXACT_ALARM` is declared but only requested when the user enables "Precise timing"; otherwise inexact-while-idle (no `USE_EXACT_ALARM`).

**ADR-051 · Accepted · Reminder planning is pure (`ReminderPlanner`): a 60-day rolling window, max 300, sorted, deduplicated, stable FNV-1a ids.** `ReminderSyncHost` rebuilds the whole schedule (cancel-all + schedule) 1.5 s after any change to people, events, commitments or reminder settings, and on every app start; the plugin's boot receiver restores schedules after a reboot. No `scheduled_notifications` table is needed because the schedule is fully derived.

**ADR-052 · Accepted · Reminders table (`owner_type`, `owner_id`, `offset_minutes`).** Events: minutes before the start time; all-day items: days (×1440) before the default reminder time. Commitments default to 30/14/7/3/1/0 days. Birthday reminders are a global setting (default: 1 day before) rather than per person.

**ADR-053 · Accepted · Commitments: stored lifecycle (active/completed/cancelled) + computed status (overdue < 0 days, due soon ≤ 7, upcoming ≤ 30, else active) from the renew-by date or the expiry.** Renewal period stored as months (`renewal_months`) instead of a full recurrence rule; renewing records history and moves expiry (and renew-by by the same number of days) in one transaction. Money as minor units + ISO code, displayed as "EGP 1,250" (codes render reliably in both languages).

**ADR-054 · Deferred · Custom commitment types.** The table supports them; the UI offers the 15 built-in types (including "Other" with a free name). A management screen can reuse the event-types pattern later.

**ADR-055 · Accepted · Notification permission is requested in context** (turning on Reminders in settings or the "Turn on" banner shown on commitment/event screens while reminders are off). Denial keeps reminders off with an explanation; a "Send a test notification" button lets the owner verify on device.
