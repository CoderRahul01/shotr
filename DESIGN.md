# shotr design system

The source of truth for how shotr looks, moves and talks. Every new screen, feature or marketing page is checked against this file. If something here is wrong, change this file first, then the product.

Reference canvas (all screens, promo, landing): https://claude.ai/artifact/7wMikfoK3Ptq7fGhjyd9jX
Product behaviour lives in SPEC.md. This file only covers design.

---

## 1. The idea in one line

**A camera for intent.** Every screenshot is a shot waiting to be developed. The UI is a dark viewfinder: quiet, precise, and one bright control that says "make it".

## 2. Principles

1. **Dark first.** Near-black canvas. Light mode is not in v1.
2. **One accent, everything else neutral.** The accent marks the one thing to do on a screen. If two things are accent, one of them is wrong.
3. **The shot metaphor is structural, not decoration.** Viewfinder corners frame screenshots. The Make button is a shutter. The logo is a viewfinder. Don't add camera clip art beyond these three.
4. **Big numbers, quiet words.** The number is the headline (To make: 12). Labels are small grey mono. Never the other way round.
5. **No guilt.** No streaks, no red badges, no "you're falling behind", no countdowns used as pressure. Recaps state facts. The weekly witness says what happened and offers one button.
6. **Fast in, fast out.** The share sheet closes in under a second and drops people back where they were. Motion never delays a task.
7. **Content is the texture.** Screenshots, drafts and numbers are the visuals. No stock photos, no illustrations of people, no gradients on UI.
8. **Honest by default.** Mark AI drafts as AI drafts. Say where data lives. Never invent stats or testimonials on marketing pages.

## 3. Color

### Accent

| Token | Hex | Use |
|-------|-----|-----|
| `accent` | `#E4F222` acid lime (default) | Primary button, shutter core, viewfinder corners on the focused shot, weekly ring, active state |
| `accent.alt` | `#FF6363` coral (approved alternate) | Same roles. Pick one per release. Never ship both at once. |
| `onAccent` | `#08090A` | Text and icons on accent |

Rules:
- Max one accent-filled control per screen. Corners and the ring count as accent "marks", not controls.
- Never use the accent for body text, links, borders of cards or decoration.
- Accent text is allowed only at 48px+ (the "made" number).

### Neutrals (surfaces go up in light, never in hue)

| Token | Hex | Use |
|-------|-----|-----|
| `bg` | `#08090A` | Canvas |
| `surface` | `#0F1011` | Cards, sheets, dock |
| `raised` | `#161718` | Thumbnails, wells, nested panels |
| `line` | `#23252A` | Hairline borders, dividers, inactive chip outline |
| `lineStrong` | `#383B3F` | Ghost button outline, focused separators |
| `textFaint` | `#62666D` | Decorative only (arrows, disabled). Fails contrast for small text. |
| `textMuted` | `#8A8F98` | Labels, metadata, placeholders |
| `textSoft` | `#D0D6E0` | Body text, chip text |
| `text` | `#FFFFFF` | Headlines, numbers, primary text |

Selected states use white, not accent: a selected chip is a white pill with dark text.

Status colors: there are none. "Expiring" and "may be closed" are neutral badges with white text on `line`. Errors use copy and an icon, not red.

## 4. Typography

| Role | Font | Size / weight / tracking |
|------|------|--------------------------|
| Hero number | Inter | 104-112px / 600 / -0.05em, tabular figures |
| Display (marketing) | Inter | clamp(52px, 7.6vw, 104px) / 600 / -0.045em / line 0.95 |
| H1 screen title | Inter | 28px / 600 / -0.022em |
| H2 onboarding | Inter | 32px / 600 / -0.022em |
| Card title | Inter | 15-16px / 500 |
| Body | Inter | 15px / 400 / line 1.5 |
| Draft text (editor) | Inter | 17px / 400 / line 1.55 |
| Quiet text | Inter | 12-13px / 400, `textMuted` |
| Mono label | Geist Mono | 10-11px / 400-500 / +0.06em / UPPERCASE, `textMuted` |

Rules:
- Two families only: Inter and Geist Mono. Enable Inter `cv01` and `ss03`.
- Never bold beyond 600.
- Mono is for metadata only: categories, ages, counts, eyebrows, status. Never for sentences.
- Numbers that change (counts, prices) use tabular figures.

Flutter: bundle Inter and Geist Mono as assets (no runtime font fetching).

## 5. Space, shape, depth

- **Grid:** 4px base. Common steps: 4, 8, 12, 16, 20, 24, 32, 48.
- **Screen gutter:** 20px (onboarding and paywall 24px).
- **Radii:** chips and pills 9999, buttons 12, cards 12 (marketing cards 16), sheets 20 top corners, thumbnails 6, capture button 14, dock 22. Nothing else.
- **Depth:** hairlines and inset highlights, not drop shadows.
  - Card: `surface` + 1px `line` (or inset `0 0 0 1px line` + `inset 0 1px 0 rgba(255,255,255,0.04)`).
  - Floating dock and phone mockups are the only elements with an outer shadow.
- **Touch targets:** 44px minimum. Primary buttons 52px tall.

## 6. Signature components

### Viewfinder corners
Four L-shaped strokes, 2px, at each corner of a framed element, offset 5px outside it. Corner length 10px (small thumbs), 14-16px (large), 22-24px (marketing headlines).
- Accent corners = this is the shot in focus (the "Make this one now" pick, the shot in the share sheet, the shot detail image).
- White corners = framed but not focused.
- Only one accent-cornered element per screen.

### Shutter (Make button)
A white 2px ring with an accent disc inside (ring size minus 14px), label "Make" in `onAccent` 600.
- Sizes: 64px (in cards), 84-88px (detail, witness), 132px (promo).
- The action's real name sits under it ("Write X/LinkedIn post", "Make it now").
- Motion: idle pulse ring every 2.8s, press scales the disc to 0.86.
- Only use the shutter for Make. Not for Save, not for navigation.

### Capture button (+ import)
A 48px rounded square (radius 14), `raised` fill, inset hairline, white plus, accent viewfinder corners inside its edges.
- Lives in the centre slot of the dock. Also shown once in onboarding ("Try it now") so people learn what it does.
- Hover: corners open outward 2px. Press: the plus rotates 90°.

### Dock (bottom nav)
Floating pill, 16px from the screen sides and 22px from the bottom, 66px tall, radius 22, `surface` at 86% with 24px blur, hairline inset.
Four equal slots: Home, Shots, Capture, Settings. Tabs are icon + 10px label. Active tab is white, inactive `textMuted`. No accent in tabs.

### Logo
Viewfinder corners (accent) around a 4px accent dot, followed by "shotr" in Inter 600, lowercase. Never write the name capitalised.

### Chips
36-44px pills. Outline `line`, text `textSoft`. Selected: white fill, dark text, optional check. Counts inside chips use mono `textMuted`.

### Buttons
- Primary: accent fill, `onAccent` text, 52px, radius 12. One per screen.
- Ghost: transparent, 1px `lineStrong`, white text.
- Make: see Shutter.
- Text link: `textSoft`, underline only on hover.

### Cards, rows, badges
- Card: `surface`, hairline, radius 12, padding 16.
- Library row: 48×68 thumbnail, title 15px, mono meta line "CATEGORY · AGE", optional badge.
- Badge: 20px tall, radius 4, `rgba(255,255,255,0.06)`, mono 10px uppercase.

### Sheets
`surface`, 20px top radius, grabber 36×4 `lineStrong`. They slide up over a 62% black scrim. Primary action pinned to the bottom.

### Abstract screenshots
Placeholders for real screenshots are built from grey bars on `raised`, never real brands or logos.

## 7. Motion

Motion explains state. It never decorates and never blocks.

| Token | Value |
|-------|-------|
| `ease.out` | cubic-bezier(.2, .8, .2, 1) (default for everything entering) |
| `ease.sheet` | cubic-bezier(.2, .9, .2, 1) |
| `dur.press` | 120-140ms |
| `dur.enter` | 500-600ms |
| `dur.count` | 1100ms, ease-out cubic |
| `stagger` | 50-100ms between siblings |

Catalogue (use these, don't invent new ones without adding them here):
- **Focus lock:** viewfinder corners slide in 9px from outside when a framed shot appears (550ms, 250ms delay).
- **Shutter pulse:** a ring expands to 1.32× and fades, every 2.8s. Press: the disc scales to 0.86.
- **Count-up:** big numbers count from 0 on first view of Home and Weekly witness.
- **Ring draw:** the weekly ring draws from 0 to its value (1.1s).
- **Rise:** cards and rows enter 14px up with opacity, staggered.
- **Sheet up:** the share sheet slides up in 500ms over a fading scrim.
- **Scan line:** a 2px accent line sweeps a thumbnail while text is read on device (the "reading" state).
- **Draft reveal:** draft paragraphs appear one by one, ending with a blinking accent cursor.
- **Shutter flash:** a white flash at 90% opacity for under 150ms. Only in onboarding, demo loops and promo.
- **Capture:** corners open on hover, the plus rotates on press.

Rules:
- Respect reduce motion: no animation, numbers show final values immediately.
- Nothing loops forever on a working screen except the shutter pulse, the scan line while reading, and the demo loop on the empty state.
- Haptics (Flutter): light impact on shutter press and Save. Nothing else.

## 8. Voice and copy

Builder-first, direct, short. Matches the founder's voice card.
- Sentences are short. Active voice. No filler.
- Sentence case everywhere. Mono labels are uppercase.
- No long em dashes. Use a period, comma, colon or hyphen.
- Banned words: delve, leverage, game-changer, tapestry, testament, synergy, unleash, beacon, landscape, revolutionize.
- Name the action, not the feature: "Write cold email", not "Generate content".
- Facts, not pressure: "Saved 14, made 3", never "Only 3? You can do better".
- Empty states give one next step: "Share your first screenshot."
- Errors say what happened and what happens next: "Saved. We'll make it when you're back online."
- Missing facts in mockups are placeholders like `[Name]`, never invented.

## 9. Accessibility

- Text contrast 4.5:1 minimum. `textFaint` is never used for readable text.
- Real buttons, inputs and labels. Icon-only buttons get a label.
- Colors that must be told apart also differ in lightness.
- Focus ring: 2px white outline, 2px offset.
- Dynamic type: layouts must survive 130% text scale without clipping.

## 10. Marketing (landing, promo, store assets)

- Same tokens as the app. The landing page is a dark page with one accent CTA per view.
- Keep it short: hero, one-screenshot-four-outcomes, three steps, pricing, final CTA. Add a section only if it changes a decision.
- Every primary CTA leads to the email waitlist until launch.
- Pricing shown as: Free ($0) and Pro ($19/month, cancel anytime).
- Hero headline: "Take screenshot. Make a shot."
- Allowed motion: word-by-word headline rise, floating phone with the promo loop, drifting framed screenshots, scroll reveal, a slow trust marquee.
- Imagery: real product UI, abstract framed screenshots, the promo loop. No stock photos, no people, no 3D blobs.
- Promo video: 16s vertical loop, `marketing/shotr-promo-1080x1920.mp4`. Scenes: screenshot pile, shutter flash, share sheet, draft, end card.

## 11. Flutter mapping

| Design token | Flutter |
|--------------|---------|
| Colors | `ShotrColors` (ThemeExtension) with the names in section 3 |
| Type | `ShotrText` (ThemeExtension) with the roles in section 4 |
| Radii, spacing | `ShotrSpace`, `ShotrRadius` constants |
| Motion | `ShotrMotion` durations and curves (`Cubic(.2, .8, .2, 1)`) |
| Components | `ViewfinderFrame`, `ShutterButton`, `CaptureButton`, `ShotrDock`, `ShotChip`, `ShotCard`, `ShotSheet` |

Material 3 base, dark `ColorScheme` seeded from the tokens above, with `useMaterial3: true`. Override ripples to a subtle white highlight. Never use default Material elevation shadows.

## 12. Checklist before shipping a screen

- [ ] One accent control at most
- [ ] Viewfinder corners only on the shot in focus
- [ ] Numbers big, labels small mono
- [ ] No guilt wording, no streaks, no red
- [ ] Motion from the catalogue, and it respects reduce motion
- [ ] 44px targets, 4.5:1 contrast
- [ ] Copy passes the voice rules (no em dashes, no banned words)
