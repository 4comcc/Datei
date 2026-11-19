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

**ADR-021 · Proposed · Android applicationId.** Recommendation: `app.datei.android` if the owner controls the `datei.app` domain, otherwise `com.<owner>.datei`. **Cannot be changed after first Play upload — owner must confirm before Phase 1.**

**ADR-022 · Proposed · Calendar UI: custom-built month/week/day views** (instead of `table_calendar`, which lacks week/day timelines and Hijri sub-labels). Final call in Phase 5.

**ADR-023 · Proposed · Sync conflict policy (future):** per-field last-writer-wins using `updated_at` + `row_version`, tombstones for deletes; revisit when sync is designed.

**ADR-024 · Accepted · No analytics/crash-reporting SDK in v1.** Simplifies Data safety declaration; may be added later as opt-in.

**ADR-025 · Accepted · Flutter 3.50 split libraries: import `package:material_ui/material_ui.dart` (and `cupertino_ui`), not `package:flutter/material.dart`.** `GlobalMaterialLocalizations`/`GlobalCupertinoLocalizations` now come from those packages; `flutter_localizations` is used only for `GlobalWidgetsLocalizations`.

**ADR-026 · Accepted (prototype only) · Prototype v0.1 stores data as JSON in SharedPreferences behind `LocalStore`.** Fast to ship for UX validation; replaced by Drift in Phase 1. The time engine, agenda service, theme, l10n and screens are kept and evolved, not thrown away.

**ADR-027 · Accepted · Fonts converted from IBM's official npm package `@ibm/plex-sans-arabic` 1.1.0 (WOFF2 → TTF via fontTools)** because Flutter cannot load WOFF; licence file shipped in `assets/fonts/`.

**ADR-028 · Accepted (revisit) · Latin digits in both languages for v0.1.** intl renders Arabic dates with Arabic-Indic digits but numbers with Latin, producing mixed text. Unified to Latin; add a Settings option "Arabic-Indic digits" that switches both dates and numbers consistently.
