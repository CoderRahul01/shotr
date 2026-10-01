# Local setup, step by step

From a blank laptop to shotr running on your phone or emulator, with the API and landing page
running locally. Commands are for macOS and Linux; Windows notes are inline.

Time: about 45 minutes the first time (mostly downloads).

---

## Part A. Install the tools (once)

### A1. Git and Node 22
- macOS: `brew install git node@22` (install Homebrew first from brew.sh)
- Windows: install Git from git-scm.com and Node 22 LTS from nodejs.org
- Check: `git --version` and `node -v` (should print v22.x)

### A2. Android Studio
1. Download from developer.android.com/studio and install.
2. First launch: pick **Standard** setup. It installs the Android SDK, platform tools and an emulator.
3. **Settings > Languages & Frameworks > Android SDK**:
   - SDK Platforms tab: tick **Android 16 (API 36)**
   - SDK Tools tab: tick **Android SDK Command-line Tools**, **Android SDK Build-Tools**, **Android Emulator**, **Android SDK Platform-Tools**
   - Apply.
4. **Device Manager > Create device > Pixel 8 > API 36 image (Google Play)** > Finish.
   Use a "Google Play" image: Google sign-in and Gemini Nano need Play services.

### A3. Java 17
Android Studio ships its own JDK. Point Flutter at it in step A5, or install Temurin 17 (adoptium.net).

### A4. Flutter 3.47.5
- macOS/Linux:
  ```bash
  git clone https://github.com/flutter/flutter.git -b 3.47.5 ~/flutter
  echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc   # or ~/.bashrc
  source ~/.zshrc
  ```
- Windows: download the 3.47.5 zip from docs.flutter.dev/release/archive, unzip to `C:\flutter`,
  add `C:\flutter\bin` to PATH.

### A5. Check everything
```bash
flutter doctor --android-licenses     # press y to accept all
flutter doctor
```
Every Android line should be green. If Java is flagged:
`flutter config --jdk-dir "/Applications/Android Studio.app/Contents/jbr/Contents/Home"` (macOS path).

iOS (optional, Mac only): Xcode 26 from the App Store, then `sudo xcode-select -s /Applications/Xcode.app`
and `sudo gem install cocoapods` (or `brew install cocoapods`).

---

## Part B. Get the code

```bash
git clone https://github.com/CoderRahul01/shotr.git
cd shotr
```

Open the folder in your editor. Read `HANDOFF.md` once; this file is the detailed version of its
"run locally" section.

---

## Part C. Landing page (2 minutes)

```bash
cd web
npm test                 # 5 tests pass
npm run dev              # http://localhost:3000
```

Open http://localhost:3000. The page, the video and the animations work.

The waitlist form shows "Could not join right now" until you connect a Google Sheet:

1. Follow `docs/google-sheet-waitlist.md` (10 minutes) to get the `/exec` URL and secret.
2. Then:
   ```bash
   cp .env.example .env          # paste the two values into .env
   set -a; source .env; set +a   # Windows PowerShell: set them with $env:NAME="value"
   npm run dev
   ```
3. Submit your email. A row appears in the sheet.

Stop with Ctrl+C.

---

## Part D. API / Worker (5 minutes)

```bash
cd ../worker
npm install
npm test                         # 16 tests pass
cp .dev.vars.example .dev.vars
```

Edit `worker/.dev.vars`:
```
OPENROUTER_API_KEY=sk-or-v1-...          # from openrouter.ai/keys (add ~$5 credit)
REVENUECAT_WEBHOOK_AUTH=Bearer local-test
```

Edit `worker/wrangler.toml`:
- `FIREBASE_PROJECT_ID` = your Firebase project ID (Part E, step E1). Until then makes return 401.
- Check `MAKE_MODEL`, `CLASSIFY_MODEL`, `VISION_MODEL` exist on openrouter.ai/models; fix the slugs if not.

Create the local database and start:
```bash
npm run db:init:local
npm run dev                      # http://localhost:8787
```

Check in another terminal:
```bash
curl localhost:8787/health       # {"ok":true}
curl -i localhost:8787/v1/me     # 401: correct, it needs a signed-in app user
```

Keep it running while you use the app.

---

## Part E. Firebase sign-in (15 minutes, needed for making drafts)

### E1. Create the project
1. console.firebase.google.com > **Add project** > name `shotr` > you can turn Analytics off.
2. Copy the **Project ID** (e.g. `shotr-1a2b3`) into `worker/wrangler.toml` > `FIREBASE_PROJECT_ID`. Restart `npm run dev`.

### E2. Turn on Google sign-in
**Build > Authentication > Get started > Sign-in method > Google > Enable** > pick your support email > Save.
Open the Google provider again and copy the **Web client ID** (ends in `.apps.googleusercontent.com`).

### E3. Connect the Flutter app
```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
cd ../app
flutterfire configure --project=<your-project-id> --platforms=android,ios
```
When asked for the Android package name, use `app.shotr`; for the iOS bundle ID, `app.shotr`.
This writes `lib/firebase_options.dart`, `android/app/google-services.json` and
`ios/Runner/GoogleService-Info.plist`.

### E4. Add your debug key fingerprint (Google sign-in fails without it)
```bash
cd android
./gradlew signingReport          # Windows: gradlew signingReport
cd ..
```
Copy **SHA1** and **SHA-256** from the `debug` variant. Firebase > Project settings > Your apps >
Android `app.shotr` > **Add fingerprint** (add both).

---

## Part F. Run the app (10 minutes)

### F1. Config
```bash
cd app                            # if not already there
cp env/example.json env/dev.json
```
Edit `app/env/dev.json`:
```json
{
  "SHOTR_API_URL": "http://10.0.2.2:8787",
  "RC_ANDROID_KEY": "",
  "RC_IOS_KEY": "",
  "GOOGLE_SERVER_CLIENT_ID": "<web client ID from E2>"
}
```
- Emulator: `10.0.2.2` is your laptop. Keep it.
- Real phone on the same Wi-Fi: use your laptop IP, e.g. `http://192.168.1.20:8787`, and start
  the Worker with `npx wrangler dev --ip 0.0.0.0`.
- RevenueCat keys can stay empty: the paywall shows "Loading…" and free makes still work.

### F2. Build and run
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter test                      # 35 tests pass
flutter analyze                   # No issues found
```
Start the emulator (Android Studio > Device Manager > play button), or plug in a phone with
**USB debugging** on (Settings > About > tap Build number 7 times > Developer options > USB debugging).
```bash
flutter devices                   # your device is listed
flutter run --dart-define-from-file=env/dev.json
```
The first build takes 3-6 minutes. After that, press `r` in the terminal for hot reload.

### F3. Walk through it
1. Onboarding: 5 screens, then **Pick 5 screenshots**.
2. Sign in with Google.
3. The photo picker opens: pick 5 screenshots (on the emulator, drag images onto the window first,
   or take some with the emulator's screenshot button).
4. Watch them read on device, then open **See my shots**.
5. Home: big "To make" number, "Make this one now", weekly ring.
6. Tap the shutter: the draft appears in your voice (uses the Worker + OpenRouter).
7. Share sheet: open Photos (or Chrome on a page), **Share > shotr**. The sheet opens over the
   other app; **Save** drops you back.
8. Turn on airplane mode and tap Make: you get "Saved. We'll make it when you're back online."
   Turn it off: the draft arrives with a notification.

---

## Part G. Optional local extras

### Payments (RevenueCat)
Needs a Play Console app with a subscription; test it on a real device installed from a Play
testing track. Details: `app/README.md` > RevenueCat. Put the public key in `RC_ANDROID_KEY`.

### Release APK on your machine
```bash
flutter build apk --release --dart-define-from-file=env/dev.json
# app/build/app/outputs/flutter-apk/app-release.apk
```
Without `android/key.properties` it's signed with the debug key: fine for testers, not for Play.

### iOS on a Mac
```bash
cd app/ios && pod install && cd ..
open ios/Runner.xcworkspace        # set your Team under Signing & Capabilities
flutter run --dart-define-from-file=env/dev.json
```
For the share sheet on iOS, follow `app/docs/ios-share-extension.md`.

---

## Troubleshooting

| Problem | Fix |
|---|---|
| `flutter doctor` says Android licenses not accepted | `flutter doctor --android-licenses` |
| Google sign-in shows error 10 / DEVELOPER_ERROR | SHA-1 missing in Firebase (E4), or wrong `GOOGLE_SERVER_CLIENT_ID` (must be the **Web** client ID) |
| Makes say "Sign in again." | `FIREBASE_PROJECT_ID` in `wrangler.toml` doesn't match the app's project; restart the Worker |
| Makes say "Something went wrong" | Check the Worker terminal: usually the OpenRouter key, credit, or a wrong model slug |
| App can't reach the API on a real phone | Use your laptop IP in `SHOTR_API_URL` and run `npx wrangler dev --ip 0.0.0.0` |
| `database.g.dart` errors | `dart run build_runner build --delete-conflicting-outputs` |
| Gradle build is slow or stuck | First build downloads a lot; give it 10 minutes. `cd android && ./gradlew --stop` then retry |
| shotr isn't in the share menu | Reinstall the app (`flutter run` again); the share target registers on install |
| Waitlist says "Could not join right now" | `.env` not loaded, or the secret doesn't match the Apps Script |
