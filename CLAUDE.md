# CLAUDE.md — Datei

Datei ("Every Date Has a Story.") is a local-first Flutter app (Android first, iOS-ready) for managing
people, events, commitments/renewals, memories, milestones, projects and timelines. Arabic (RTL) and
English (LTR) are first-class from v1.

## Read first
- `docs/PRD.md` — product scope and acceptance criteria
- `docs/ARCHITECTURE.md` — layers, folder layout, state management, engines
- `docs/DATABASE_SCHEMA.md` — Drift tables, constraints, migrations policy
- `docs/DECISIONS.md` — ADRs (append, never rewrite history; supersede instead)
- `docs/ROADMAP.md` — phase status (update at the end of every phase)
- `docs/AUTHENTICATION_SETUP.md` — Firebase / Google / Facebook console setup

## Binding working rules
1. One phase at a time. Briefly state the plan before starting a phase.
2. After every phase: `flutter analyze` (zero issues) + relevant tests green. Do not advance with open errors.
3. No TODO in place of a core feature. No fake/demo data in production paths.
4. All date/time math lives in `lib/core/time_engine` and `lib/core/recurrence_engine`. Never re-implement it elsewhere.
5. No business logic inside widgets. Widgets → providers (Riverpod) → use cases / repositories.
6. Every user-visible string goes through ARB localization (`lib/app/localization/l10n/*.arb`). Use
   directional widgets/props (`EdgeInsetsDirectional`, `AlignmentDirectional`, `start`/`end`) — never left/right.
7. No new package without checking: maintained, null-safe, compatible with current Flutter/Dart, actually needed.
   Record notable additions in `docs/DECISIONS.md`.
8. Never commit secrets: `google-services.json`, `firebase_options.dart`, `android/secrets.properties`,
   keystores and `key.properties` are git-ignored. No dummy credentials to make auth "look" working.
9. Never claim a feature works until it is implemented and tested. Auth is "ready" only after a real
   device/emulator test with real provider configuration.
10. Don't delete existing files without understanding them.
11. Storage of dates: civil dates as `YYYY-MM-DD` text; instants as UTC epoch millis + IANA tz id. Gregorian is
    the storage reference; Hijri is display/input only.

## Commands (once the Flutter project exists — Phase 1)
```
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --release   # requires Android SDK + signing config
flutter build appbundle --release
```

## Definition of Done (per feature)
Designed · logic complete · persisted where needed · inputs validated · errors handled · integrated with other
modules · tests pass · works in Arabic and English · correct RTL/LTR.
