# Take Screenshot -> Make a Shot

<!-- Source: Screenshot_App_Product_Spec_v1.docx. Converted to Markdown, content unchanged except the decisions log below. -->

## Decisions log

Changes agreed after v1 of this spec. Where these conflict with the text below, these win.

| Date | Decision | Replaces |
|------|----------|----------|
| 2026-10-01 | Pricing is **shotr Pro, $19/month** (subscription, cancel anytime). Free tier unchanged: unlimited saving, reading, sorting, search + 5 makes. | "One plan: Lifetime" (Paywall, Usage rules, Flow E, RevenueCat non-consumable). RevenueCat now sells one monthly subscription. "Lifetime users" in Low-text screenshots means Pro users. |
| 2026-10-01 | First run order: onboarding 1-5, "Try it now" screen, then sign-in, then the photo picker opens. | Clarifies Flow A. |
| 2026-10-01 | Landing page "Get early access" goes to an email waitlist. | New. |
| 2026-10-01 | Design language lives in DESIGN.md. | New. |



Product spec v1: screens, logic, flows, edge cases, tech


## 1. App structure

- Bottom nav (3 tabs): Home, Shots, Settings
- Center "+" button: import screenshots from gallery
- Outside the app: share sheet receiver (the main way shots come in)

## 2. Screens


### Onboarding (5 screens, taps only)

- Hook: "Take screenshot -> make a shot." 3-step visual: screenshot, share, done. Button: "Show me"
- What do you screenshot? Multi-select chips: Content ideas, Startup playbooks, AI updates, Hiring posts, Learning, Product ideas
- Where should they end up? Multi-select: X/LinkedIn posts, Cold emails, Build notes, Learning notes, Just organized
- Your voice: paste 2 or 3 posts or emails you wrote. "Skip" visible.
- Try it now: "Pick 5 recent screenshots." Opens the photo picker. This is the aha moment, so don't skip it.

### Sign-in

- Google sign-in. On iOS, add Apple sign-in too.
- Placed after onboarding so they've already invested.

### Home (dashboard)

- Big number: "To make: 12"
- "Make this one now" card: one pick from the priority logic (section 3)
- This week: saved vs made, one ring
- Category chips with counts, tap to filter
- Recent shots row
- Free users only: "3 of 5 free shots left"

### Shots (library)

- Tabs: To make / Made / Archived
- Search bar (searches the extracted text)
- Filter by category
- Each row: thumbnail, title, category, age ("9 days"), expiry badge for hiring posts

### Share receiver sheet


Pops up over X, LinkedIn, Gallery, anywhere.

- Thumbnail
- Auto-detected category (one tap to change)
- Optional one-line note: "Why did you save this?" This captures intent at the moment it's freshest.
- Two buttons: Save (default) and Make now
- Closes fast and drops them back where they were

### Shot detail

- Screenshot (tap to zoom)
- Gist: 1 line of what it is
- Your note, if any
- Main button picked by category (e.g. "Write cold email")
- "Do something else" chips: Post, Email, Build note, Takeaways
- Change category, archive, delete

### Result / editor

- Draft in your voice, editable
- Quick tweaks: Shorter, Punchier, More personal
- 1 free regenerate per shot
- Copy, Share (opens X, LinkedIn, Gmail via share sheet)
- "AI draft" label + report button (Play policy)
- Sharing auto-marks the shot as made

### Weekly witness


Opens from the Sunday notification.

- "Saved 14, made 3"
- Oldest waiting shot, with one button: "Make it now"

### Paywall

- One plan: Lifetime
- What's included: all shot types, voice profile, weekly witness, monthly fair-use shots, future updates
- Restore purchase link

### Settings

- Voice profile (edit samples)
- Categories you care about
- Witness day and time
- Account: sign out, delete account and data (required by both stores)
- Restore purchase
- Privacy: "Images stay on your phone"

### Empty and error states

- No shots yet: "Share your first screenshot" + 5-second demo loop
- All made: "Inbox zero. Go screenshot something."
- No internet: "Saved. We'll make it when you're back online."

## 3. Product logic


### Shot lifecycle

- new -> reading -> ready -> made / archived / failed
- Reading text and sorting work offline. Only "make" needs internet.

### Priority (picks the "make this now" card)

- Expiring first: hiring posts older than 5 days
- Then categories the user picked in onboarding
- Then oldest
- Never show the same pick 3 days in a row, rotate it

### Classification

- Fixed list in v1: content idea, startup playbook, AI update, hiring post, learning, product idea, other
- Output per shot: category, title, 1-line gist, suggested action, expires yes/no
- When the user corrects a category, save it. Later these become examples for the classifier.

### Usage rules

- Free: unlimited saving, reading, sorting, search + 5 free makes
- Lifetime: monthly fair-use cap (set after you measure real cost per make)
- Failed or empty AI responses never count against quota
- 1 free regenerate per shot, quick tweaks count as 0

### Low-text screenshots (UI, charts, photos)

- If text is under ~15 words, ask: "What's this about?" (free, one line)
- Lifetime users can send the image to a vision model instead

### Sensitive content guard

- If the text looks like an OTP, card number, password, or bank details: warn and never send it to the cloud

### Your skill.md

- Lives on the server as the system prompts, one per shot type
- You can improve prompts without shipping an app update

## 4. Flows


### A. First run


Open -> 5 onboarding screens -> sign in -> pick 5 screenshots -> reading -> dashboard fills up -> first free make -> share it -> "that's the app"


### B. Daily capture (the core loop)


Screenshot -> Share -> sheet -> auto category -> optional note -> Save -> back to the app they were in


### C. Make


Card or shot detail -> Make -> quota check -> AI draft -> tweak -> copy/share -> marked made


### D. Weekly witness


Sunday notification -> recap -> make the oldest one


### E. Paywall triggers


Free makes run out, or user taps a locked action, or from Settings -> lifetime purchase -> unlocked instantly


### F. New phone


v1 data lives only on the phone. Say this clearly in Settings. v1.1: sync text only (not images) to the cloud.


## 5. Edge cases

- Multiple images shared at once: batch them, cap at 20
- Links or text shared (not images): accept as a text shot. Lots of people share links, this is free extra value.
- Duplicate screenshot: detect by image hash, show "already saved"
- OCR returns nothing or gibberish: fall back to the "What's this about?" question
- Mixed languages: ML Kit reads Latin and Devanagari scripts, so Hindi plus English works
- Text inside the screenshot tries to command the AI ("ignore previous instructions"): treat screenshot text as data only, guard it in the system prompt
- Hiring post too old: badge "may be closed", still let them make the email
- No internet during make: queue it, notify when the draft is ready
- AI returns junk: retry once silently, then show error, quota not charged
- Purchase pending (UPI, slow cards): show "pending", unlock on confirm
- Refund: lock makes, keep all their data
- Original deleted from gallery: fine, the app keeps its own compressed copy
- Storage growing: compress copies, setting "delete my copy after made"
- Notification permission: ask after the first save, never at launch
- Very long screenshots: cap the text sent to the model
- On-device AI unavailable: fall back to the cloud classifier quietly

## 6. Tech decision


### Rust + Kotlin: no

- Kotlin alone is Android only, so you'd build iOS twice
- Rust has no production-ready mobile UI layer, it only adds a bridge to maintain
- The app's heavy work is reading text and calling AI. Rust speeds up neither.

### React Native: works, but second place

- Fine for the UI and payments
- On-device AI and ML Kit plugins are less mature there

### Flutter: pick this

- One codebase for Android and iOS
- Flutter + Claude Code workflow already set up earlier, so no restart
- Plugins exist for every piece needed, including on-device AI

### Latest tech worth using (free, on-device)

- Gemini Nano via ML Kit Prompt API: moved from alpha to beta in January 2026, runs on 140M+ devices. No API key, no server, no per-request bill.
- Apple Foundation Models on iOS: same idea, Apple's built-in model
- One Flutter plugin covers both: flutter_native_ai wraps both behind one small Dart API
- Catch: iOS needs version 26+ with Apple Intelligence on, and Android's side is beta with no SLA. Always keep the cloud fallback.

### Full stack

- App: Flutter, Riverpod (state), go_router (navigation), Drift (local SQLite database)
- Input: share-intent plugin (receive_sharing_intent, check it's maintained before committing) + image_picker (uses Android's photo picker, no permissions)
- Text reading: google_mlkit_text_recognition (on-device, free)
- Sorting: Gemini Nano / Apple model on supported phones -> small cloud model fallback
- Making: Cloudflare Worker (TypeScript + Hono) -> OpenRouter
- Usage + entitlement records: Cloudflare D1 (free tier)
- Auth: Firebase Auth. The Worker verifies the Firebase token on every call.
- Payments: RevenueCat, one non-consumable "lifetime" product
- Notifications: flutter_local_notifications (local, free, no server)

### Request path

- On phone: share/picker -> copy to app storage -> ML Kit reads text -> sensitive check -> on-device sort (or Worker fallback) -> save to Drift
- On make: app -> Worker (Firebase token) -> check entitlement + quota in D1 -> OpenRouter with the skill.md prompt -> draft back -> saved on phone

## 7. Build order (7 days)

- Day 1: Flutter setup, onboarding, sign-in, share receiver
- Day 2: OCR, sorting, Drift database, Shots list
- Day 3: Worker + OpenRouter, shot detail, result screen
- Day 4: dashboard, priority logic, weekly witness
- Day 5: RevenueCat paywall, settings, delete account
- Day 6: edge cases, empty states, upload to closed testing
- Day 7: fix tester bugs, "did we make it" post