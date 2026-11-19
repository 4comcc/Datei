# Datei — Every Date Has a Story.

Local-first Flutter app (Android first) for people, events, commitments, memories and timelines, in Arabic and English.

**Status:** Prototype v0.1 — see `docs/ROADMAP.md`.

## Build
Requirements: Flutter 3.50 stable, Android SDK 36, JDK 17+.
```bash
flutter pub get
flutter gen-l10n
flutter analyze
flutter test
flutter build apk --release
```
The APK is written to `build/app/outputs/flutter-apk/app-release.apk` (prototype is signed with the debug key — not for Play upload).

## Docs
`CLAUDE.md`, `docs/PRD.md`, `docs/ARCHITECTURE.md`, `docs/DATABASE_SCHEMA.md`, `docs/DECISIONS.md`, `docs/ROADMAP.md`, `docs/AUTHENTICATION_SETUP.md`.

Fonts: IBM Plex Sans Arabic, SIL Open Font License 1.1 (`assets/fonts/OFL-IBMPlexSansArabic.txt`).
