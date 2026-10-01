# shotr app (Flutter)

Android first, iOS from the same codebase. Product rules: `../SPEC.md`. Design rules: `../DESIGN.md`.

## Stack

| Concern | Choice |
|---|---|
| State | Riverpod 3 |
| Navigation | go_router (onboarding, sign-in and first-pick gates in `lib/app/router.dart`) |
| Local data | Drift (SQLite). v1 data lives only on the phone |
| Capture | `receive_sharing_intent` (share sheet) + `image_picker` (system photo picker, no permission) |
| Reading text | `google_mlkit_text_recognition`, Latin + Devanagari, on device |
| Sorting | Gemini Nano / Apple Foundation Models (`flutter_native_ai`) -> Worker -> offline keyword rules |
| Making | Cloudflare Worker (`../worker`) -> OpenRouter |
| Auth | Firebase Auth: Google (Android + iOS), Apple (iOS) |
| Payments | RevenueCat: one monthly subscription, shotr Pro $19/month, entitlement `pro` |
| Notifications | `flutter_local_notifications` (weekly witness, draft ready). Asked after the first save |

## Layout

```
lib/
  main.dart                 bootstrap (Firebase optional in dev)
  app/                      app widget, router, gate, providers, share intake
  core/theme/               tokens from DESIGN.md + Material theme
  core/widgets/             ViewfinderFrame, ShutterButton, CaptureButton, chips, buttons, motion
  domain/                   pure rules: categories, priority pick, sensitive guard, low-text, classifier
  data/                     Drift database, repository, settings
  services/                 OCR, classifier chain, ingest, make, API, auth, purchases, notifications
  features/                 onboarding, auth, home, shots, share, detail, result, witness, paywall, settings
test/                       domain, repository (in-memory SQLite), widgets
```

## Run it

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # Drift codegen
flutter run --dart-define=SHOTR_API_URL=http://10.0.2.2:8787   # Worker running locally
flutter analyze && flutter test
```

Without Firebase configured the app runs signed out (sign-in screen is skipped) so you can build
UI and capture flows locally. Makes need the Worker and a signed-in user.

### Build-time settings (`--dart-define`)

| Key | What |
|---|---|
| `SHOTR_API_URL` | Worker URL, e.g. `https://api.shotr.app` |
| `RC_ANDROID_KEY` / `RC_IOS_KEY` | RevenueCat public SDK keys |
| `GOOGLE_SERVER_CLIENT_ID` | Web OAuth client ID (Firebase > Auth > Google), needed for the ID token on Android |

Put them in a file and use `--dart-define-from-file=env/prod.json` (gitignore it).

## One-time setup before launch

### 1. Firebase
1. Create a Firebase project. Enable **Authentication > Google** and **Apple**.
2. `dart pub global activate flutterfire_cli && flutterfire configure --platforms=android,ios`
   (replaces `lib/firebase_options.dart`, adds `android/app/google-services.json` and
   `ios/Runner/GoogleService-Info.plist`).
3. Add your debug and release **SHA-1 / SHA-256** to the Android app in Firebase (Google sign-in).
4. iOS: put `REVERSED_CLIENT_ID` from `GoogleService-Info.plist` in `ios/Runner/Info.plist`
   (replace `com.googleusercontent.apps.REPLACE_ME`).
5. Set `FIREBASE_PROJECT_ID` in `../worker/wrangler.toml`.

### 2. RevenueCat ($19/month)
1. Play Console and App Store Connect: create a subscription product, e.g. `shotr_pro_monthly`, $19/month.
2. RevenueCat: entitlement `pro`, attach the product; offering `default` with a **Monthly** package.
3. Copy the public SDK keys into `RC_ANDROID_KEY` / `RC_IOS_KEY`.
4. Webhook: URL `https://<worker>/v1/revenuecat/webhook`, Authorization header = the value of the
   Worker secret `REVENUECAT_WEBHOOK_AUTH`. The app user ID is the Firebase UID.

### 3. Worker
See `../worker/README.md`.

### 4. Android release
```bash
keytool -genkey -v -keystore ~/shotr-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```
Create `android/key.properties` (gitignored):
```
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/absolute/path/to/shotr-upload.jks
```
Then `flutter build appbundle --release --dart-define-from-file=env/prod.json` and upload
`build/app/outputs/bundle/release/app-release.aab` to Play Console (internal / closed testing first).

Application ID: `app.shotr`. minSdk 26 (needed by Gemini Nano). Change the ID before the first
upload if you want a different one; it can't change after.

### 5. iOS release
Follow `docs/ios-share-extension.md`, then set your Team in Xcode and
`flutter build ipa --release --dart-define-from-file=env/prod.json`.
Bundle ID: `app.shotr`. Minimum iOS 15.5 (ML Kit). On-device sorting needs iOS 26 with Apple
Intelligence on, otherwise it falls back to the Worker quietly.

## Store checklist

- [ ] Privacy policy URL (state: images stay on the phone; extracted text is sent only to make a draft; email for the account)
- [ ] Play Data safety: account email, app activity (usage counts). No photos collected
- [ ] Account deletion: in-app (Settings > Delete account and data) plus a web URL for Play
- [ ] AI-generated content: "AI draft" label and report button on every draft (Play policy)
- [ ] App Store: Sign in with Apple offered next to Google (done on iOS)
- [ ] Subscription terms shown on the paywall: price, monthly renewal, cancel in store account (done)
- [ ] Screenshots and promo video: `../marketing/`
