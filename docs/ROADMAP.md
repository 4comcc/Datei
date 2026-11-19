# Datei — Roadmap

Legend: ✅ done · 🔄 in progress · ⏳ not started · ⛔ blocked

| Phase | Title | Status | Exit criteria |
|---|---|---|---|
| 0 | Inspection & planning | ✅ 2026-11-19 | Environment report, planning docs, open decisions listed |
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
2. Android SDK access: allow `dl.google.com` in the environment network policy (needed for `flutter build apk/appbundle`; analysis and unit/widget tests work without it).
3. A Git remote (GitHub repo) to persist work — the container is ephemeral.
4. Phase 3 only: Firebase project + Google/Facebook console configuration (see AUTHENTICATION_SETUP.md).
5. Phase 10 only: real Android device or emulator for integration and real-auth tests (cannot run in this container; needs KVM/device).
