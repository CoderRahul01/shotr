# shotr handoff

Everything you need to clone, run, configure and ship shotr. Read top to bottom once; after that,
use the checklists.

- Product rules: `SPEC.md` (decisions log at the top wins). Design rules: `DESIGN.md` (don't change).
- Design canvas: https://claude.ai/artifact/7wMikfoK3Ptq7fGhjyd9jX

---

## 1. What's in the repo

| Folder | What | Runs on | Cost |
|---|---|---|---|
| `app/` | Flutter app, Android + iOS | phones | free (Play $25 once, Apple $99/yr) |
| `worker/` | API: auth check, quota, AI makes, RevenueCat webhook | Cloudflare Workers + D1 | free tier |
| `web/` | Landing page + `/api/waitlist` | Vercel | free (Hobby) |
| `marketing/` | Promo loop, 21s launch video | - | - |
| `docs/` | Google Sheet waitlist setup | - | - |

Why the API isn't on Vercel: the stack in SPEC is Cloudflare Worker + D1, and the app already talks to
it. Vercel hosts the marketing site and the waitlist. Both are free and both deploy from GitHub.

**Status:** analyzer clean, 35 app tests, 16 Worker tests, 5 waitlist tests passing. Landing page and
Worker were run locally end to end. An Android APK has **not** been built yet (the sandbox couldn't
download the Android SDK). CI builds it on GitHub; see section 6.

---

## 2. Clone and run locally (about 15 minutes)

**Full step-by-step guide, from a blank laptop: `docs/LOCAL_SETUP.md`.** Short version below.

You need: Flutter 3.47.5, Android Studio (for the emulator and SDK), Node 22, Git.

```bash
git clone https://github.com/CoderRahul01/shotr.git && cd shotr
```

### Landing page + waitlist
```bash
cd web
cp .env.example .env            # fill after section 4, or leave empty to test the page only
set -a; source .env; set +a
npm run dev                     # http://localhost:3000
node --test test/*.test.js
```

### Worker (API)
```bash
cd worker
npm install
cp .dev.vars.example .dev.vars  # put your OpenRouter key in it
npm run db:init:local
npm run dev                     # http://localhost:8787/health -> {"ok":true}
npm test
```

### App
```bash
cd app
flutter pub get
dart run build_runner build --delete-conflicting-outputs
cp env/example.json env/dev.json   # edit values
flutter test
flutter run --dart-define-from-file=env/dev.json   # with an emulator or USB phone attached
```

Without Firebase configured the app runs signed out: onboarding, capture, reading, sorting, Home,
Shots, share sheet and Settings all work. **Making a draft needs Firebase + the Worker** (section 3).
On the Android emulator the Worker on your laptop is `http://10.0.2.2:8787`. On a real phone use
your laptop's LAN IP, or the deployed URL.

Test the share sheet: open Photos on the emulator, share any screenshot, pick **shotr**.

---

## 3. Keys and accounts

### Minimum for a working beta (makes work, no payments yet)
| What | Where to get it | Goes into |
|---|---|---|
| Firebase project | console.firebase.google.com (free) | `flutterfire configure` (generates files) and `FIREBASE_PROJECT_ID` in `worker/wrangler.toml` |
| Google web client ID | Firebase > Auth > Sign-in method > Google > Web SDK config | `GOOGLE_SERVER_CLIENT_ID` in `app/env/*.json` |
| SHA-1 + SHA-256 of your keys | `cd app/android && ./gradlew signingReport` | Firebase > Project settings > Android app |
| OpenRouter API key + about $5 credit | openrouter.ai/keys | `OPENROUTER_API_KEY` (Worker secret) |
| Cloudflare account | dash.cloudflare.com (free) | `npx wrangler login`, then the D1 `database_id` in `wrangler.toml` |
| Google Sheet webhook | `docs/google-sheet-waitlist.md` | `SHEET_WEBHOOK_URL`, `SHEET_WEBHOOK_SECRET` (Vercel) |

### For payments ($19/month Pro)
| What | Where | Goes into |
|---|---|---|
| RevenueCat project | app.revenuecat.com (free under $2.5k/mo revenue) | `RC_ANDROID_KEY`, `RC_IOS_KEY` |
| Play subscription `shotr_pro_monthly` $19/month | Play Console > Monetize > Subscriptions | RevenueCat product, entitlement `pro`, offering `default` > Monthly |
| Webhook auth string (make one up) | RevenueCat > Integrations > Webhooks | `REVENUECAT_WEBHOOK_AUTH` (Worker secret) and the RevenueCat Authorization header |

### Every env var, by place
| Place | Variables |
|---|---|
| `app/env/dev.json` / `prod.json` | `SHOTR_API_URL`, `RC_ANDROID_KEY`, `RC_IOS_KEY`, `GOOGLE_SERVER_CLIENT_ID` |
| App files (generated, from Firebase) | `app/lib/firebase_options.dart`, `app/android/app/google-services.json`, `app/ios/Runner/GoogleService-Info.plist` |
| Worker vars (`wrangler.toml`) | `FIREBASE_PROJECT_ID`, D1 `database_id`, `FREE_MAKES=5`, `PRO_MONTHLY_MAKES=300`, model slugs, `WAITLIST_ORIGINS` |
| Worker secrets | `OPENROUTER_API_KEY`, `REVENUECAT_WEBHOOK_AUTH` |
| Vercel | `SHEET_WEBHOOK_URL`, `SHEET_WEBHOOK_SECRET` |
| GitHub > Settings > Secrets (release builds) | `GOOGLE_SERVICES_JSON`, `FIREBASE_OPTIONS_DART`, `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEY_PROPERTIES` |
| GitHub > Settings > Variables | `SHOTR_API_URL`, `RC_ANDROID_KEY`, `GOOGLE_SERVER_CLIENT_ID` |

`ANDROID_KEY_PROPERTIES` is the three lines `storePassword=…`, `keyPassword=…`, `keyAlias=upload`.
`ANDROID_KEYSTORE_BASE64` is `base64 -w0 upload.jks`. Never commit either.

---

## 4. Deploy

### 4a. Landing page on Vercel (connected to this repo)
1. vercel.com > **Add New > Project** > import `CoderRahul01/shotr`.
2. **Root Directory: `web`**. Framework preset: **Other**. Build command: empty. Output directory: `.`
3. Environment variables: `SHEET_WEBHOOK_URL`, `SHEET_WEBHOOK_SECRET` (set up the sheet first: `docs/google-sheet-waitlist.md`).
4. Deploy. Every push to `main` redeploys; every PR gets a preview URL.
5. Domains: add `shotr.app` and `www.shotr.app`, follow Vercel's DNS steps.
6. Test: submit your email on the live site, check the sheet. Signup count: `=COUNTA(B2:B)`.

### 4b. Worker on Cloudflare
```bash
cd worker
npx wrangler login
npx wrangler d1 create shotr             # paste database_id into wrangler.toml
npm run db:init                           # remote schema
npx wrangler secret put OPENROUTER_API_KEY
npx wrangler secret put REVENUECAT_WEBHOOK_AUTH
# edit wrangler.toml: FIREBASE_PROJECT_ID; check model slugs on openrouter.ai/models
npm run deploy
```
Then in Cloudflare add a custom domain `api.shotr.app` to the Worker. Put that URL in `SHOTR_API_URL`.

**Verify the model slugs** in `wrangler.toml` (`MAKE_MODEL`, `CLASSIFY_MODEL`, `VISION_MODEL`) against
openrouter.ai/models before the first deploy. The sandbox couldn't reach OpenRouter to confirm them.

---

## 5. Manual things only you can do

- [ ] Firebase project, enable Google (and Apple for iOS) sign-in, run `flutterfire configure --platforms=android,ios`
- [ ] Add SHA-1/SHA-256 (debug, upload key, and later Play App Signing key) to Firebase
- [ ] iOS only: replace `com.googleusercontent.apps.REPLACE_ME` in `app/ios/Runner/Info.plist` with `REVERSED_CLIENT_ID`
- [ ] Cloudflare: D1, secrets, deploy, `api.shotr.app`
- [ ] OpenRouter key and credit
- [ ] Google Sheet + Apps Script (`docs/google-sheet-waitlist.md`)
- [ ] Vercel project, env vars, `shotr.app` domain
- [ ] Upload keystore: `keytool -genkey -v -keystore upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload` (back it up somewhere safe)
- [ ] GitHub secrets and variables from section 3
- [ ] Privacy policy page (Play requires a URL). Can be a page on the landing site
- [ ] AI images for the landing page (section 7)
- [ ] Later: RevenueCat + Play subscription for Pro; Apple developer account for iOS

---

## 6. Getting the app to people

### Today, free: APK on GitHub Releases
1. Do the "minimum for a working beta" keys and the GitHub secrets/variables.
2. `git tag v0.1.0 && git push origin v0.1.0`
3. The `release-android` workflow builds the APK and AAB and attaches them to a GitHub Release.
4. Send the APK link to your waitlist. Testers allow "install unknown apps" once.

You can also run it by hand: GitHub > Actions > **release-android** > Run workflow (artifact only, no release).
The `app` workflow builds a test APK on every push to `app/` (Actions > app > artifact `shotr-android-apk`).

Optional, also free: Firebase App Distribution (testers get an invite email and updates).

### Play Store
1. Play Console account: $25 once. Create app `shotr`, package `app.shotr`.
2. Upload `app-release.aab` to **Closed testing**. New personal accounts must run a closed test with
   **at least 12 testers for 14 days** before production. Use your waitlist: put testers in a Google
   Group and add the group to the track.
3. Fill in: Data safety (account email, usage counts; no photos collected), content rating,
   target audience, privacy policy URL, account deletion URL, app access instructions for review.
4. Store listing assets: icon 512×512, feature graphic 1024×500, at least 2 phone screenshots
   (1080×1920). The promo video can go on YouTube for the listing.
5. After 14 days: apply for production.

### iOS
Apple Developer ($99/yr) > follow `app/docs/ios-share-extension.md` on a Mac > TestFlight.

---

## 7. Landing page images (Nano Banana / Gemini, Higgsfield, Midjourney)

The page already has slots. **Missing files render nothing**, so drop them in whenever they're ready.
Save as WebP (quality ~80) into `web/assets/img/`, then push.

| File | Size (ratio) | Where it shows |
|---|---|---|
| `hero.webp` | 2400×1350 (16:9) | soft glow behind the phone in the hero, faded at the edges |
| `story.webp` | 2520×1080 (21:9) | full-width band under the video (desktop) |
| `story-mobile.webp` | 1600×1200 (4:3) | same band on phones |
| `og.jpg` | 1200×630 | link previews on X, LinkedIn, WhatsApp (currently a frame from the launch video) |

Style rules (from DESIGN.md): near-black `#08090A`, one acid-lime `#E4F222` accent, no other colors,
no readable text, no logos, no faces, calm and premium, lots of negative space.

**hero.webp**
> Cinematic macro photograph in near-total darkness, background pure #08090A. A few translucent glass
> cards shaped like phone screenshots float at different depths, softly out of focus, edges catching a
> thin acid-lime (#E4F222) rim light. Subject centered, edges fade to black. Shallow depth of field,
> subtle film grain, minimal, premium tech product mood. No text, no logos, no people. 16:9.

**story.webp** (and the same prompt at 4:3 for `story-mobile.webp`)
> Moody night-time photo of a modern smartphone lying on a dark matte desk, seen from a low 3/4 angle.
> The screen glows softly and shows an abstract blurred screenshot framed by four thin acid-lime
> (#E4F222) corner brackets like a camera viewfinder. Everything else is near-black (#08090A) with
> gentle falloff. Minimal, calm, editorial, shallow depth of field. No readable text on the screen,
> no logos, no hands, no faces. 21:9 ultra-wide composition with the phone in the right third.

**og.jpg**: better made from the design than generated (AI images mangle text). Keep the current
frame, or screenshot the hero at 1200×630.

---

## 8. Prompt to continue in Claude Code / Antigravity / Cursor

Paste this as the first message in a fresh session at the repo root:

```text
You're continuing work on shotr, a Flutter app (Android first, iOS next) that turns screenshots
into posts, cold emails, build notes and takeaways in the user's voice.

Read these first, in order: HANDOFF.md, SPEC.md (the decisions log at the top overrides the rest),
DESIGN.md, app/README.md, worker/README.md.

Rules:
- Do not change the design. Every UI change must follow DESIGN.md: one accent color, viewfinder
  corners only on the shot in focus, shutter button only for Make, motion from the catalogue,
  no streaks or guilt wording, no em dashes in copy.
- Don't add features that aren't in SPEC.md unless I ask.
- Keep the architecture: Riverpod providers in app/lib/app/providers.dart, pure rules in
  app/lib/domain (with tests), data in app/lib/data (Drift), side effects in app/lib/services,
  screens in app/lib/features. Backend changes go in worker/ with tests in worker/test.
- After every change run: `cd app && flutter analyze && flutter test`, and
  `cd worker && npm run typecheck && npm test` when the Worker changes.
- Commit in small, clear commits on a feature branch and open a PR to main.

First task: <describe the feature or fix here>.
```

---

## 9. Known gaps and next steps

1. **First real Android build.** Watch the `app` workflow on GitHub. If it fails, paste the log into your
   agent with "fix the Android build". (The last failure was a plugin needing Android SDK 37;
   `receive_sharing_intent` is now pinned to 1.8.1 to fix it.)
2. **Device testing:** share sheet from X/LinkedIn/Photos, OCR on Hindi + English, offline queue, weekly witness notification.
3. **Pro fair-use cap** (`PRO_MONTHLY_MAKES=300`) is a placeholder. Measure cost per make in OpenRouter and set it.
4. **iOS Share Extension** needs the one-time Xcode setup.
5. **Text-only sync** to the cloud is planned for v1.1 (SPEC flow F). Not built.
