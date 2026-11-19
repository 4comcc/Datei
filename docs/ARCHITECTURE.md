# Datei — Architecture

## 1. Overview
Clean Architecture, feature-first, local-first.

```
Presentation (widgets, screens, Riverpod notifiers/providers)
      │  depends on
Domain (entities, value objects, repository interfaces, use cases) ── pure Dart, no Flutter/Drift imports
      ▲  implemented by
Data (Drift DAOs, mappers, repository implementations, platform services)
Core (time engine, recurrence engine, database, notifications, backup, security, auth service, errors)
Shared (design-system widgets, extensions, common models)
```
Rules: Domain never imports Data/Presentation. Widgets never touch DAOs. All date math goes through
`core/time_engine` + `core/recurrence_engine`.

## 2. Technology (verified 2026-11-19 on pub.dev; re-check at Phase 1 `pub get`)
| Concern | Choice | Version at planning |
|---|---|---|
| SDK | Flutter stable / Dart | 3.50.0 / 3.14.0 |
| State | flutter_riverpod + riverpod_annotation/generator | 3.5.0 / 4.0.x |
| Routing | go_router (StatefulShellRoute for bottom nav) | 18.1.x |
| DB | drift + drift_flutter + drift_dev (sqlite via `sqlite3` native assets; `sqlite3_flutter_libs` is EOL — do not add) | 2.35.x / 0.3.1 |
| Models | freezed + freezed_annotation, json_serializable | 4.0.x / 3.1 / 6.15 |
| i18n | flutter_localizations + intl + ARB (`flutter gen-l10n`) | intl 0.20.x |
| Notifications | flutter_local_notifications + timezone + flutter_timezone | 23.x / 0.11 / 5.1 |
| Storage | flutter_secure_storage (secrets, PIN hash, backup keys), shared_preferences (light prefs) | 11.2 / 2.5 |
| Auth | firebase_core, firebase_auth, google_sign_in (v7 Credential-Manager API), flutter_facebook_auth | 5.2 / 7.1 / 7.2 / 7.3 |
| Security | local_auth (biometrics), cryptography (AES-GCM, Argon2id/PBKDF2) | 3.0 / 2.9 |
| Hijri | `hijri` (Umm al-Qura table) wrapped behind `HijriConverter` interface + user day-offset | 3.0.x |
| Charts | fl_chart | 1.3.x |
| Files | path_provider, image_picker, file_picker, share_plus, archive (zip) | — |
| CSV | csv | 8.x |
| IDs | uuid (v4/v7) | 4.6 |
| Branding | flutter_launcher_icons, flutter_native_splash (dev only) | — |
| Tests | flutter_test, integration_test, mocktail | — |

Every package is re-validated (maintenance, compatibility) when first added; additions logged in DECISIONS.

## 3. Folder structure
```
lib/
  main.dart                       # bootstrap: bindings, tz init, Firebase (if configured), ProviderScope
  app/
    app.dart                      # MaterialApp.router, locale, theme, directionality
    router/                       # GoRouter config, guards (onboarding, app-lock), route names
    theme/                        # ColorScheme (olive/gold), typography (IBM Plex Sans Arabic/Plex Sans), component themes
    localization/l10n/            # app_en.arb, app_ar.arb (+ generated)
  core/
    database/                     # AppDatabase, tables/, daos/, migrations/, converters
    errors/                       # Failure types, Result<T>
    utils/
    services/                     # clock (injectable Clock), file storage, image compression
    time_engine/                  # LocalDate, age, diffs, next birthday/anniversary, Hijri adapter
    recurrence_engine/            # RecurrenceRule model, occurrence expansion, exceptions, edit scopes
    notifications/                # scheduler, rolling window planner, boot/tz-change rescheduling
    backup/                       # export/import, manifest, integrity hash, encryption
    security/                     # PIN hashing, app lock state, biometrics
    authentication/               # AuthService interface, FirebaseAuthService, provider adapters
  features/<feature>/
    domain/   (entities, repositories (abstract), usecases)
    data/     (repository impl, mappers, DAO usage)
    presentation/ (screens, widgets, providers/notifiers)
    # features: onboarding, language_selection, authentication, home, people, events, calendar,
    # commitments, memories, milestones, projects, timeline, search, reports, settings, account
  shared/ widgets/ models/ extensions/
assets/ branding/ fonts/ icons/ images/
test/ unit/ widget/  integration_test/   docs/
```

## 4. State management
- Riverpod 3 with code generation. Repositories and services exposed as providers (DI root = `ProviderScope`; tests override).
- Read models are **streams** from Drift (`watch…`) → `StreamProvider`/`AsyncNotifier`; UI reacts to DB changes, no manual refresh.
- A single `clockProvider` supplies "now" so time-dependent logic is deterministic in tests.

## 5. Navigation
GoRouter with `StatefulShellRoute.indexedStack`: Home · People · Events · Calendar · More.
Global FAB/speed-dial on shell: Add person / event / commitment / memory.
Redirect chain: `languageChosen?` → `onboardingDone?` → `appLocked?` → shell. Deep links reserved for notifications (`/events/:id`, `/commitments/:id`, `/people/:id`).

## 6. Time model (core/time_engine)
- `LocalDate` value type (y/m/d, no time zone) for birthdays, all-day events, due dates. Stored `YYYY-MM-DD`.
- `LocalTime` (HH:mm) optional for timed items + IANA `tzId` captured at creation; instants computed via `timezone` package (DST-safe). Instants persisted as UTC epoch ms only where an absolute moment is meaningful (notification fire times, audit timestamps).
- Age: full years/months/days between birth `LocalDate` and target date; Feb-29 birthdays celebrated on **Feb 28 in non-leap years** by default (configurable: Feb 28 / Mar 1) — see ADR-009.
- Functions: age, ageAt, daysBetween, monthsBetween, yearsBetween, remainingDays, elapsedDays, nextBirthday, nextAnniversary, nextOccurrence, diff (Y/M/D), Gregorian↔Hijri.

## 7. Recurrence (core/recurrence_engine)
- RFC 5545-inspired `RecurrenceRule`: freq (daily/weekly/monthly/yearly), interval, byWeekday, byMonthDay, bySetPos (e.g. "last Friday"), until | count, plus month-end/Feb-29 overflow policy.
- Only the series is stored. Occurrences expanded lazily for a window `[from,to]`.
- `recurrence_exceptions`: cancelled or overridden occurrence (original date → override fields).
- Edit scopes: *this occurrence* (exception), *this and following* (split series: end old at prev occurrence, create new series), *all* (edit rule).

## 8. Notifications
- `flutter_local_notifications.zonedSchedule`. Android caps pending alarms (~500); we schedule a **rolling window** (next 60 days, ≤ 300 notifications, nearest first) and replan on: app start, any reminder-affecting change, device boot (`RECEIVE_BOOT_COMPLETED`, handled by plugin), timezone/time change, app update.
- Inexact by default; exact alarms only if user enables "precise reminders" and grants `SCHEDULE_EXACT_ALARM` (Android 12+). Android 13+: `POST_NOTIFICATIONS` runtime request in context.
- Mapping table `scheduled_notifications` (notification int id ↔ entity, occurrence, fire time) for idempotent replanning.

## 9. Authentication (core/authentication + features/authentication, account)
- `AuthService` interface: `authState` stream, `signInWithGoogle`, `signInWithFacebook`, `linkProvider`, `signOut`, `deleteAccount`, `reauthenticate`. Firebase implementation; a `NoopAuthService` when Firebase is not configured (UI shows "sign-in unavailable in this build", guest still fully functional).
- Google: `google_sign_in` v7 (`GoogleSignIn.instance.initialize(serverClientId: …)` → `authenticate()` → idToken) → `GoogleAuthProvider.credential` → Firebase.
- Facebook: `flutter_facebook_auth` login with `['email','public_profile']` only → access token → `FacebookAuthProvider.credential`.
- Account linking: Firebase "one account per email"; on `account-exists-with-different-credential` the app asks the user to sign in with the existing provider, then `linkWithCredential` the pending credential.
- **Local data ownership:** a single `local_user_profile` row (device owner, created at first run, `guest` until bound). On sign-in, `account_metadata` stores firebase uid/provider info and the profile becomes bound — **no data is moved or copied**, so guest→registered is lossless and duplicate-free. Signing in with a *different* uid than the bound one prompts the user (keep data / start empty profile requires explicit confirm). Sign-out keeps local data (option to wipe, explicit).
- Sign-in never triggers upload. Cloud sync (future) is a separate opt-in module.

## 10. Future cloud sync readiness
UUID primary keys; `created_at`, `updated_at`, `deleted_at` (soft delete tombstones) on syncable tables; `row_version` counter; `owner_profile_id`. A future `sync_outbox` table + `SyncService` can be added without changing domain code. Conflict policy candidates documented in DECISIONS.

## 11. Backup
`.datei` file = zip: `manifest.json` (app version, schema version, created at, counts, SHA-256 per entry), `data.json` (all tables), `attachments/…`. Optional encryption: whole archive AES-256-GCM, key from password via Argon2id (salt + params in a cleartext header). Restore = validate → confirm → transaction replace (with automatic pre-restore safety backup) → reschedule notifications. Older schema backups upgraded by mapping functions; newer rejected.

## 12. Security
App lock (PIN hashed with PBKDF2/Argon2id + salt in secure storage; biometrics via local_auth) gate on cold start and on resume after configurable timeout. `FLAG_SECURE` optional for recents screenshot hiding. No analytics SDKs in v1.

## 13. Error handling
Repositories return `Result<T, Failure>`; Failure is localized at presentation. Unexpected errors caught in a root zone and logged locally (no remote crash reporting without consent).

## 14. Testing
Unit (time/recurrence engines exhaustively, repositories with in-memory Drift), DB (CRUD, FKs, migrations via drift_dev schema dumps), auth (mocked FirebaseAuth/providers), widget (AR/EN, RTL/LTR golden-ish checks), integration_test on emulator.
