# Datei branding

Chosen direction: **A — Geometric D** (owner decision 2026-11-19, see ADR-036).
A solid geometric "D" (stem + bowl) with a soft-gold point inside: a single moment in time.

| File | Use |
|---|---|
| `datei_icon.svg` | Master app icon (rounded square, olive background) |
| `datei_icon_square.svg` | Full-bleed square (stores, legacy launchers) |
| `datei_icon_foreground.svg` | Adaptive-icon foreground (transparent, fits the 66/108 dp safe zone) |
| `datei_icon_monochrome.svg` | Android 13+ themed icon layer (single colour) |
| `datei_mark_olive.svg` | Mark on light surfaces |
| `datei_wordmark.svg` / `png/datei_wordmark*.png` | Mark + "Datei" (IBM Plex Sans Arabic Bold) |
| `png/` | Rendered PNGs (1024 icon, Play Store 512, wordmark light/dark) |
| `concepts/` | The three explored directions and the comparison sheet |

Palette: olive `#596B35`, cream `#F4F1E7`, soft gold `#D6B66A`, dark olive `#3F4D28`, charcoal `#252A20`.
Geometry: the in-app `DateiLogo` widget draws the same path (`lib/shared/widgets/datei_logo.dart`).
Regenerate Android/web PNGs with `tool/render_branding.js` (Playwright + Chromium).
