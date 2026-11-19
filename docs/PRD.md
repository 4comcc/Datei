# Datei — Product Requirements Document

**Tagline:** Every Date Has a Story.
**Version:** v1.0 (initial release) · **Platform:** Android first (phones + tablets), architecture iOS-ready
**Languages:** Arabic (RTL), English (LTR) — both first-class from day one

## 1. Vision
Datei is a personal manager for everything tied to a date: the people in a user's life, their ages and
occasions, events and memories, life milestones, commitments and renewals, and light personal projects.
It is **not** a birthday reminder; it is a flexible, offline-first system for time-anchored information.

## 2. Target users
- Individuals who want to remember family/friends' dates and life events.
- Professionals tracking renewals (domains, hosting, SSL, licences, insurance, IDs, passports, contracts).
- Anyone who wants a structured personal timeline.

## 3. Principles
1. **Local-first.** Every core feature works offline with no account.
2. **Privacy by default.** No data leaves the device without explicit consent. No contacts/friends harvesting.
3. **Bilingual by design.** Real RTL, natural translations, locale-aware dates and numbers.
4. **Correct time math.** Leap years, Feb 29, month lengths, timezones and DST handled centrally.
5. **Calm, elegant UI.** Material 3, olive/gold palette, generous whitespace.

## 4. Scope v1 (must have)
| # | Module | Summary |
|---|--------|---------|
| M1 | Onboarding | First-run language picker (العربية / English, device language pre-selected but user decides), welcome screen, auth choice |
| M2 | Authentication | Google, Facebook (via Firebase Auth), Guest. Account page, sign-out, delete account, credential linking, guest → registered without data loss |
| M3 | Home dashboard | Today summary (Gregorian + optional Hijri), today's events, upcoming, birthdays (turning age, days left), important reminders, overdue count, quick actions; sections re-orderable/hideable |
| M4 | People | Full profile, optional photo, birth date (year optional), categories (many-to-many), directed relationships, custom fields, age engine, multi-criteria filter, saved filters, person timeline |
| M5 | Events | Built-in + custom types, single/multi-day, all-day or timed, linked people, location, priority, colour, recurrence, reminders, attachments, status |
| M6 | Calendar | Month / week / day views, jump to date, filter by type, search, Gregorian/Hijri toggle, Hijri input with manual offset |
| M7 | Commitments & renewals | Types (domain, hosting, SSL, contract, licence, insurance, warranty, subscription, bill, payment, instalment, passport, ID, vehicle licence, custom), amounts/currency, recurrence, multi-offset reminders, computed statuses, renewal history |
| M8 | Memories | Dated notes with people, event, photos/attachments, tags, category |
| M9 | Milestones | Life milestones linked to person / project / event |
| M10 | Projects & goals | Light: name, description, dates, status, priority, people, events, notes |
| M11 | Timeline | Global and per-person; past/present/future; filters by type and period |
| M12 | Search | Unified search across all entities, structured filters, AND/OR groups, saved filters |
| M13 | Notifications | Local, multiple reminders per item, recurring, birthday/commitment/deadline, survive reboot & app update |
| M14 | Reports | Counts and distributions, charts, CSV export with Arabic (UTF-8 BOM) |
| M15 | Backup & restore | Full JSON backup including attachments, schema version, integrity check, optional password encryption, confirmation before restore, import/export per entity |
| M16 | Settings | Language, theme (light/dark/system), date & calendar prefs, Hijri, notifications, account, data & privacy, security |
| M17 | Security | App lock with PIN and biometrics, secure storage, privacy policy |

## 5. Out of scope for v1 (architecture must allow later)
Cloud sync, AI assistant, home-screen widgets, premium tier, iOS release, web.

## 6. Key user stories & acceptance criteria (selection)
- **First launch:** user sees language picker before anything else; choice persists; never shown again; changeable in Settings; whole UI flips direction immediately.
- **Guest:** "Continue as guest" gives full access to every core module; no feature is gated behind sign-in.
- **Sign in later:** a guest who signs in keeps 100% of local data — no deletion, no duplication.
- **Sign-in ≠ sync:** signing in uploads nothing in v1.
- **Age:** for a person born 2000-02-29, on 2025-02-28 age is 24, on 2025-03-01 age is 25 (rule documented in DECISIONS); "turning N in D days" always correct; age never stored.
- **Birthday without year:** supported; age hidden, next birthday still shown.
- **Recurring event:** one stored rule; occurrences computed; edit this / this-and-following / all.
- **Commitment:** reminders at 30/14/7/3/1/0 days or custom; status computed (Upcoming/Due soon/Overdue…); "Renew" creates a history entry and advances dates.
- **Backup:** export → wipe → restore yields identical data and attachments; wrong password fails cleanly; newer-schema backup is rejected with a clear message.
- **Delete account:** removes provider account (with re-auth if needed); local data is kept or deleted only per explicit user choice.

## 7. Non-functional
- Smooth on mid-range Android (60 fps lists, paginated queries, indexed columns, lazy images, compressed photos).
- Accessibility: contrast ≥ 4.5:1 for body text, scalable fonts, TalkBack labels, ≥ 48dp touch targets.
- Min Android: API 24 (Android 7.0). Target: latest API level required by Google Play at release time.
- Play compliance: Data safety form, privacy policy URL, in-app + web account-deletion path, minimal permissions.

## 8. Success metrics (post-launch)
Crash-free sessions ≥ 99.5%, notification delivery reliability, D30 retention, % users with ≥ 10 people/events.
