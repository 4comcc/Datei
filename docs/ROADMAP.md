# Datei — Roadmap

Legend: ✅ done · 🔄 in progress · ⏳ not started · ⛔ blocked

| Phase | Title | Status | Exit criteria |
|---|---|---|---|
| 0 | Inspection & planning | ✅ 2026-11-19 | Environment report, planning docs, open decisions listed |
| P | Prototype v0.1 (owner request) | ✅ 2026-11-19 | Installable APK to try the UX: language picker, welcome, guest, home, people, events, month calendar, settings |
| 1 | Foundation | ⏳ | Flutter project, folder structure, Riverpod, GoRouter shell (5 tabs + quick add), Drift DB v1 (settings/profile/account tables + seeds), ARB AR/EN, RTL/LTR, M3 theme light/dark, fonts; analyze clean; smoke tests |
| 2 | Branding & onboarding | ⏳ | 3 icon directions presented → owner picks; adaptive icon, wordmark, splash; language picker (first-run only), welcome, auth choice screen, Guest mode |
| 3 | Authentication | ⏳ | AuthService + Firebase impl, Google, Facebook, linking, account page, sign-out, delete (re-auth), guest→registered; mocked tests; **real-config device test before marking ready** |
| 4 | People | ⏳ | Persons CRUD, categories, relationships, custom fields, age engine (+tests), filters + saved filters, profile screen |
| 5 | Events & calendar | ⏳ | Events CRUD, types, people links, recurrence engine (+tests), exceptions & edit scopes, month/week/day calendar, Hijri |
| 6 | Commitments & reminders | ⏳ | Commitments, statuses, renewals history, reminders, local notifications w/ rolling window, boot reschedule |
| 7 | Memories, milestones, timeline, projects | ⏳ | CRUD + global & per-person timeline with filters |
| 8 | Search & reports | ⏳ | FTS unified search, AND/OR filter builder, saved filters, charts, CSV (UTF-8 BOM) |
| 9 | Backup & security | ⏳ | .datei backup/restore with attachments, encryption, integrity, app lock PIN/biometric, privacy policy |
| 10 | QA & release | ⏳ | Full test suite, perf pass, translation & RTL review, real auth tests, signed APK + AAB, Play listing & Data safety |

## Phase 0 outcome (2026-11-19)
- Project folder was empty → **new project**.
- Flutter 3.50.0 stable installed at `/opt/flutter` in the (ephemeral) cloud container; Android SDK **not available** (dl.google.com blocked by environment network policy).
- Docs created: CLAUDE.md, PRD, ARCHITECTURE, DATABASE_SCHEMA, DECISIONS, ROADMAP, AUTHENTICATION_SETUP.

## Blockers / prerequisites before Phase 1
1. Owner confirms Android applicationId (ADR-021).
2. ~~Android SDK access~~ — resolved 2026-11-19 (hosts allowed; SDK 36 installed in container).
3. A Git remote (GitHub repo) to persist work — the container is ephemeral.
4. Phase 3 only: Firebase project + Google/Facebook console configuration (see AUTHENTICATION_SETUP.md).
5. Phase 10 only: real Android device or emulator for integration and real-auth tests (cannot run in this container; needs KVM/device).

## Prototype v0.1 (2026-11-19)
Built at the owner's request before Phase 1 to validate the experience.
- Implemented: first-run language picker (AR/EN, persisted, changeable), RTL/LTR, welcome screen, guest mode, bottom navigation (Home/People/Events/Calendar/More) + quick-add, Home dashboard (today, birthdays, upcoming events), People CRUD with search & category filter, age breakdown, next birthday, Events CRUD (types, optional time, yearly repeat, linked people), month calendar with birthday/event markers, theme (light/dark/system), erase data, provisional icon.
- Not in prototype (by design): Google/Facebook sign-in (buttons explain it's coming), Drift DB, notifications, commitments, memories, milestones, timeline, reports, backup, Hijri, app lock.
- Quality: `flutter analyze` clean; 17 tests (time engine, agenda, widget flow AR/EN) passing.
- Android SDK installed after `dl.google.com` + `downloads.gradle.org` were allowed in the environment.
