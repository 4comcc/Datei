# Authentication Setup — Firebase, Google, Facebook

Status: **not configured.** Nothing below has been created; no credentials exist in the repository.
The code (Phase 3) will build and run without these files in guest-only mode. Sign-in is declared
"working" only after a successful test on a real device/emulator with this configuration.

## 0. Values the owner must decide/provide
| Item | Where it goes | Secret? |
|---|---|---|
| Android applicationId (e.g. `app.datei.android`) | Firebase, Facebook, Gradle | No (permanent!) |
| Debug keystore SHA-1 & SHA-256 | Firebase Android app | No |
| Upload keystore SHA-1 & SHA-256 | Firebase | No (keystore itself **is** secret) |
| Play App Signing key SHA-1 & SHA-256 (Play Console → App integrity) | Firebase + Facebook key hash | No |
| `google-services.json` | `android/app/` (git-ignored) | Treat as private |
| `lib/firebase_options.dart` (from `flutterfire configure`) | git-ignored; `firebase_options.example.dart` committed | Treat as private |
| Google Web client ID (`serverClientId`) | `--dart-define=GOOGLE_SERVER_CLIENT_ID=…` or local config | No, but keep out of repo |
| Facebook App ID + Client Token | `android/secrets.properties` (git-ignored) → Gradle `resValue` | Client Token: **secret** |
| Privacy policy URL, account-deletion web URL, Facebook data-deletion URL | Play Console, Facebook app, in-app | No |

## 1. Firebase project
1. https://console.firebase.google.com → Add project "Datei" (Analytics: **off** — see ADR-024).
2. Add Android app with the applicationId; add debug + upload + Play signing SHA-1/SHA-256.
3. Authentication → Sign-in method: enable **Google** and **Facebook**.
4. Authentication → Settings → User account linking: **"Link accounts that use the same email"** (one account per email).
5. Authentication → Settings → Authorized domains: keep defaults.
6. Download `google-services.json` → `android/app/` (do not commit).
7. Locally: `dart pub global activate flutterfire_cli && flutterfire configure --project=<id> --platforms=android` → generates `lib/firebase_options.dart` (do not commit).

## 2. Google Sign-In (google_sign_in v7 + Credential Manager)
1. Enabling Google in Firebase auto-creates OAuth clients in Google Cloud project; the **Web client (auto created by Google Service)** ID is the `serverClientId`.
2. Google Cloud Console → APIs & Services → OAuth consent screen (Google Auth Platform → Branding): app name "Datei", support email, logo, privacy policy URL, authorized domain. Scopes: `openid`, `email`, `profile` only (non-sensitive → no verification review).
3. Android OAuth client is created per SHA-1 (Firebase does this when SHA is added). After Play upload, add the **Play App Signing** SHA-1 or release sign-in will fail with `DEVELOPER_ERROR`/code 10.
4. App passes `serverClientId` at `GoogleSignIn.instance.initialize(...)`.

## 3. Facebook Login
1. https://developers.facebook.com → My Apps → Create app → use case **"Authenticate and request data from users with Facebook Login"**.
2. Settings → Basic: App name, contact email, **Privacy Policy URL**, **User Data Deletion** (instructions URL or callback), category, app icon.
3. Add Android platform: package name = applicationId, default activity class `<applicationId>.MainActivity`, **key hashes** = base64(SHA-1) of debug, upload and Play signing keys:
   `keytool -exportcert -alias <alias> -keystore <ks> | openssl sha1 -binary | openssl base64`
   (for the Play signing key convert its SHA-1 hex from Play Console to base64).
4. Facebook Login → Permissions: `public_profile`, `email` (both default; no App Review needed).
5. Copy **App ID**, **App Secret**, **Client Token**.
6. Firebase → Authentication → Facebook provider: paste App ID + App Secret; copy Firebase's **OAuth redirect URI** into Facebook Login → Settings → Valid OAuth Redirect URIs.
7. Switch the Facebook app to **Live** mode before release (Development mode only allows app roles/testers).
8. Local file `android/secrets.properties` (git-ignored):
   ```
   facebookAppId=...
   facebookClientToken=...
   ```
   Gradle injects them as `facebook_app_id`, `fb_login_protocol_scheme` (`fb<appId>`), `facebook_client_token` string resources.

## 4. Account deletion & policy compliance
- In-app: Settings → Account → Delete account → re-authenticate (Firebase `requires-recent-login`) → `user.delete()`; Facebook: also revoke permissions (`/me/permissions` DELETE via plugin logout+revoke where supported). Local data: user chooses keep or erase (explicit confirmation).
- Google Play requires a **web URL** where users can request account deletion without the app — prepare a simple page (e.g. GitHub Pages/website) before release.
- Facebook requires the data-deletion instructions URL/callback.
- Play Data safety: declare "Personal info → Name, Email, User IDs" collected for "Account management" when signed in; data stays on device otherwise; no sharing; encryption in transit (Firebase).

## 5. Testing checklist (must pass on device before "ready")
- [ ] Google: first sign-in creates account; second sign-in reuses it; cancel → back to screen with no error toast spam; airplane mode → localized network error.
- [ ] Facebook: same matrix + declined email permission handled.
- [ ] Same email via Google then Facebook → linking flow, single Firebase user with 2 providers.
- [ ] Guest with data → sign in → all data present, counts unchanged.
- [ ] Sign out → local data still present (unless user chose wipe).
- [ ] Delete account → re-auth prompt when stale → user removed from Firebase console.
- [ ] Release build signed with upload key, installed from Play internal testing track → both providers work (Play signing SHA registered).
