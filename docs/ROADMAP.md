# Datei — Roadmap

Legend: ✅ done · 🔄 in progress · ⏳ not started · ⛔ blocked

| Phase | Title | Status | Exit criteria |
|---|---|---|---|
| 0 | Inspection & planning | ✅ 2026-11-19 | Environment report, planning docs, open decisions listed |
| P | Prototype v0.1 (owner request) | ✅ 2026-11-19 | Installable APK to try the UX: language picker, welcome, guest, home, people, events, month calendar, settings |
| 1 | Foundation | ✅ 2026-11-19 | Flutter project, folder structure, Riverpod, GoRouter shell (5 tabs + quick add), Drift DB v1 (settings/profile/account tables + seeds), ARB AR/EN, RTL/LTR, M3 theme light/dark, fonts; analyze clean; smoke tests |
| 2 | Branding & onboarding | ✅ 2026-11-19 | 3 icon directions presented → owner picks; adaptive icon, wordmark, splash; language picker (first-run only), welcome, auth choice screen, Guest mode |
| 3 | Authentication | ⏳ (deferred until Firebase/Facebook setup by owner) | AuthService + Firebase impl, Google, Facebook, linking, account page, sign-out, delete (re-auth), guest→registered; mocked tests; **real-config device test before marking ready** |
| 4 | People | ✅ 2026-11-20 | Persons CRUD, categories, relationships, custom fields, age engine (+tests), filters + saved filters, profile screen |
| 5 | Events & calendar | ✅ 2026-11-20 | Events CRUD, types, people links, recurrence engine (+tests), exceptions & edit scopes, month/week/day calendar, Hijri |
| 6 | Commitments & reminders | ✅ 2026-11-20 (device-tested by owner) | Commitments, statuses, renewals history, reminders, local notifications w/ rolling window, boot reschedule |
| 7 | Memories, milestones, timeline, projects | ✅ 2026-11-20 | CRUD + global & per-person timeline with filters |
| 8 | Search & reports | ✅ 2026-11-20 | FTS unified search, AND/OR filter builder, saved filters, charts, CSV (UTF-8 BOM) |
| 9 | Backup & security | ✅ 2026-11-20 | .datei backup/restore with attachments, encryption, integrity, app lock PIN/biometric, privacy policy |
| 10 | QA & release | ⏳ | Full test suite, perf pass, translation & RTL review, real auth tests, signed APK + AAB, Play listing & Data safety |

## Phase 0 outcome (2026-11-19)
- Project folder was empty → **new project**.
- Flutter 3.50.0 stable installed at `/opt/flutter` in the (ephemeral) cloud container; Android SDK **not available** (dl.google.com blocked by environment network policy).
- Docs created: CLAUDE.md, PRD, ARCHITECTURE, DATABASE_SCHEMA, DECISIONS, ROADMAP, AUTHENTICATION_SETUP.

## Blockers / prerequisites before Phase 1
1. ~~Owner confirms Android applicationId~~ — `com.fourcom.datei` (ADR-021).
2. ~~Android SDK access~~ — resolved 2026-11-19 (hosts allowed; SDK 36 installed in container).
3. ~~Git remote~~ — https://github.com/4comcc/Datei (`main`).
4. Phase 3 only: Firebase project + Google/Facebook console configuration (see AUTHENTICATION_SETUP.md).
5. Phase 10 only: real Android device or emulator for integration and real-auth tests (cannot run in this container; needs KVM/device).

## Prototype v0.1 (2026-11-19)
Built at the owner's request before Phase 1 to validate the experience.
- Implemented: first-run language picker (AR/EN, persisted, changeable), RTL/LTR, welcome screen, guest mode, bottom navigation (Home/People/Events/Calendar/More) + quick-add, Home dashboard (today, birthdays, upcoming events), People CRUD with search & category filter, age breakdown, next birthday, Events CRUD (types, optional time, yearly repeat, linked people), month calendar with birthday/event markers, theme (light/dark/system), erase data, provisional icon.
- Not in prototype (by design): Google/Facebook sign-in (buttons explain it's coming), Drift DB, notifications, commitments, memories, milestones, timeline, reports, backup, Hijri, app lock.
- Quality: `flutter analyze` clean; 17 tests (time engine, agenda, widget flow AR/EN) passing.
- Android SDK installed after `dl.google.com` + `downloads.gradle.org` were allowed in the environment.

## Phase 1 outcome (2026-11-19)
- applicationId/namespace `com.fourcom.datei`.
- Drift database schema v1 (`lib/core/database`): local_user_profiles, account_metadata, app_settings, persons, person_categories, person_category_relations, event_types, recurrence_rules, events, event_person_relations; FKs on, CHECK constraints, indexes, idempotent system seeds; schema snapshot `drift_schemas/datei/drift_schema_v1.json`.
- Clean layering: domain repository interfaces (people, events, settings, data maintenance) → Drift implementations → Riverpod providers → screens. Prototype `LocalStore` removed.
- Bootstrap before first frame: local profile, one-time prototype import, settings load.
- Tests: 31 passing (time engine, agenda, repositories CRUD/soft-delete/recurrence/links, constraints, erase-all, legacy import, widget flows AR/EN). `flutter analyze`: no issues.
- Not in Phase 1 (planned): custom categories/types UI (Phase 4/5), full recurrence engine (Phase 5), tz capture (ADR-034), account linking (Phase 3).

## Phase 2 outcome (2026-11-19)
- Three icon directions presented with real-size previews; owner chose **A — Geometric D** (ADR-036).
- `assets/branding/`: SVG sources (icon, square, adaptive foreground, monochrome, olive mark, wordmark), PNG renders (1024 icon, Play Store 512, wordmark light/dark), README.
- Android: legacy + adaptive launcher icons (all densities), Android 13 themed (monochrome) icon, Android 12+ splash (light/dark) and pre-12 launch screen in brand colours. Web icons/favicon updated.
- In-app `DateiLogo` redrawn with the final geometry. Onboarding (language picker, welcome, guest) already in place since v0.1/v0.2.
- `flutter analyze` clean; 34 tests passing.

## Phase 4 outcome (2026-11-20)
- Schema v2 (+ migration & tests): `persons.birth_year_known`, `person_relationships`, `custom_field_definitions`, `custom_field_values`, `saved_filters`.
- Categories: built-in + user-created (name, colour), manage screen (More → Categories), quick-add from the person form.
- Relationships: directed, to me or to another person, custom labels, shown both ways on profiles, removed with the person.
- Person data: gender (optional), workplace, address, custom fields (text/number/date/url) with validation; birth date with optional year.
- Age: breakdown, days lived, age on any chosen date, months/days until next birthday.
- People list: text search + advanced filter sheet (categories, age range, birth month/day/year, has birth date, birthday within 7/30/90 days, occupation, workplace, relationship type), saved filters (long-press to delete), result count.
- Fixed during testing: a disposed-controller crash in the filter-name dialog; RTL ordering of user values like "O+".
- `flutter analyze` clean; 59 tests (unit, database, migration, widget AR/EN).
- Phase 3 (authentication) is deferred until the owner creates the Firebase project and Facebook app.

## Phase 5 outcome (2026-11-20)
- Recurrence engine + 17 tests; series splitting + tests.
- Schema v3 (`event_exceptions`) with verified migrations v1→v3 and v2→v3.
- Events: end date/time (multi-day), priority, status, custom types (More → Event types), full recurrence editor, edit/delete scopes (this / this and following / all), Hijri date entry.
- Calendar: month / week / day (hour timeline) views, jump to date, filter by type and birthdays, search (±1 year), Hijri day numbers and month names.
- Settings: show Hijri, Hijri adjustment −2…+2 days; Home shows today's Hijri date.
- Fixed during testing: navigation crash when a form is opened without history; Hijri dialog field overflow; an outdated Phase 4 test assertion.
- `flutter analyze` clean; 104 tests.

## Phase 6 outcome (2026-11-20)
- Schema v4: commitment_types (15 built-in), commitments, commitment_renewals, reminders; verified migrations v1…v4.
- Commitments: list with status filters, form (type, provider, expiry, renew-by, start, period, amount+currency, reference, link, reminders, status), detail with renew dialog and renewal history; Home "Important reminders" and overdue count; commitments on the calendar (filterable) and in calendar search; quick add.
- Reminders: per-event offsets (at time / minutes / hours / days), per-commitment days, birthday reminders setting, default reminder time, precise timing (exact alarms on request), test notification, notification tap opens the right screen (also when launching the app).
- Planner + sync: 60-day rolling window, stable ids, rebuilt on changes and app start; boot receiver.
- `flutter analyze` clean; 131 tests (planner, rules, repositories, migrations, widget flows with a fake notification gateway).
- Device test (owner, 2026-11-20): v0.6.0 installed; reminders, test notification and scheduled notifications confirmed working.

## Phase 7 outcome (2026-11-20)
- Schema v5 with verified migrations v1…v5.
- Memories: list, form (date, text, photos from the system picker, people, linked event, tags with suggestions, category), detail with photo grid and zoomable full-screen viewer; quick add; latest memories on each person's page.
- Milestones: 9 kinds, linked to person/project/event; list and form; quick add.
- Projects & goals: list (open first, past-due badge), form, detail (people, related events, milestones).
- Timeline: global (More → Timeline) and per person; periods all / past year / this year / upcoming; type filters; today marker.
- `flutter analyze` clean; 151 tests.
- Device check needed: picking photos from the gallery on the owner's phone.

## Phase 8 outcome (2026-11-20)
- Unified search (Home → search icon, More → Search) across people, events, commitments, memories, milestones and projects, Arabic-aware.
- Advanced conditions with match all / match any; saved searches (long-press to delete).
- Reports: totals, upcoming 7/30/90 days, people by category, age distribution, birthdays by month, events by type, commitments by status.
- CSV export of people, events, commitments and memories via the share sheet.
- Fixed during the phase: reversed number ranges in Arabic (bidi isolates), invisible characters in source replaced with escapes.
- `flutter analyze` clean; 164 tests. One unidentified test failed once during a full run and did not recur in 7 consecutive runs — to investigate in Phase 10 (likely timing-dependent).

## Phase 9 outcome (2026-11-20)
- Backup & restore (Settings → Data → Backup & restore): `.datei` file with all data and photos, optional password (Argon2id + AES-256-GCM), SHA-256 checks, saved/opened with the system file dialogs; restore shows a summary, asks for confirmation, keeps an automatic safety copy (with "Undo the last restore") and replaces data in one transaction. Damaged, foreign and newer files are rejected; wrong passwords can be retried.
- App lock (Settings → Security & privacy): 4–8 digit PIN (salted PBKDF2 in the Keystore-backed secure storage), optional fingerprint/face unlock, lock again immediately / after 1 / 5 minutes, increasing lockout after 5 wrong PINs; change/turn off needs the PIN.
- In-app privacy policy (Arabic/English) + `docs/PRIVACY_POLICY.md`. Android auto cloud backup turned off.
- Fixed during testing: restore did not refresh open screens (Drift streams not notified); restore wiped this device's settings; decompression errors not reported as "damaged"; a crafted backup could name files outside the attachments folder.
- `flutter analyze` clean; 190 tests.
- Device check needed: fingerprint prompt, PIN lock after leaving the app, backup to Drive/Files and restore with photos and password.
