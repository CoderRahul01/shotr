# AI asset prompts (Nano Banana + Veo in Gemini)

Ready-to-paste prompts for every image and video slot on the landing page and the store listing.
Written against `DESIGN.md`, so the results match the product instead of looking like stock AI art.

- **Images:** Gemini app > Create image (Nano Banana), or Google AI Studio with `gemini-2.5-flash-image`.
- **Video:** Gemini app > Video (Veo 3.1), or AI Studio / Flow. Best results: make the still with Nano
  Banana first, then animate that still with Veo (image-to-video). The style stays locked.

The landing page already has the slots. Missing files render nothing, so add them in any order.

---

## The style block (paste at the start of every prompt)

> Style: premium dark product photography for a minimal mobile app brand. Background is near-black
> #08090A, almost pure black with deep soft falloff. One accent color only: acid lime #E4F222, used as
> thin light lines and small glows, never as a big fill. Everything else is neutral black, graphite
> and soft white. Calm, precise, editorial, lots of negative space, shallow depth of field, subtle film
> grain. No other colors. No gradients of purple, blue or teal. No glowing blobs, no neon cityscapes,
> no holograms, no abstract "AI brain" imagery. No text, no logos, no watermarks, no people's faces,
> no hands.

**The brand motif to ask for: "viewfinder corners".** Four thin L-shaped brackets, like a camera
autofocus frame, around the one thing in focus. Say it exactly that way in the prompt.

---

## 1. Story band (landing page, below the video)

Files: `web/assets/img/story.webp` (2520×1080, 21:9) and `web/assets/img/story-mobile.webp` (1600×1200, 4:3)

**Nano Banana prompt (21:9):**
> [style block] A modern smartphone lying flat on a dark matte charcoal desk at night, seen from a low
> three-quarter angle, placed in the right third of a very wide 21:9 frame. The phone screen glows
> softly and shows an abstract, blurred screenshot of a social post (gray bars instead of text), framed
> by four thin acid-lime #E4F222 viewfinder corner brackets, like a camera locking focus. A faint lime
> reflection of the brackets on the desk surface. The left two thirds of the frame are empty black with
> gentle falloff. Shot on a 50mm lens at f/1.8, very shallow depth of field. Aspect ratio 21:9.

**Same prompt for mobile:** replace the last sentence with "Phone centered, aspect ratio 4:3."

**Check before using:** no readable text on the screen, no extra colors, brackets are thin (not thick
neon tubes), the phone has no brand logo.

## 2. Story band video (optional, replaces the still)

File: `web/assets/video/story.mp4` (1920×1080 or larger, 8 s, seamless loop, no audio)

**Veo prompt (image-to-video, start from story.webp):**
> Keep the exact composition, lighting and colors of the input image. Very slow camera push-in toward
> the phone, about 5 percent over 8 seconds, perfectly smooth, no shake. The four acid-lime viewfinder
> brackets on the screen gently contract inward by a few pixels and settle, like autofocus locking,
> then a soft white flash lasts a few frames as if a screenshot was taken, then the screen glow returns
> to calm. Nothing else moves. No new objects, no text, no people, no hands. Silent. Seamless loop:
> the last frame matches the first.

Export: `ffmpeg -i in.mp4 -an -c:v libx264 -crf 24 -preset slow -pix_fmt yuv420p -movflags +faststart -vf "scale=1920:-2" story.mp4` (aim for under 4 MB).

## 3. Link preview image (X, LinkedIn, WhatsApp)

File: `web/assets/img/og.jpg` (1200×630). Currently a frame from the launch video, which is fine.

**Nano Banana prompt (if you want a custom one):**
> [style block, but allow text] A 1200×630 social preview card. Pure #08090A background. On the left, in a
> clean geometric sans-serif (like Inter Semibold), large white text on two lines: "Take screenshot."
> and "Make a shot." The second line is framed by four thin acid-lime #E4F222 viewfinder corner
> brackets. Small lowercase wordmark "shotr" in the top left with a tiny lime bracket icon. On the right,
> a dark smartphone at a slight angle showing a blurred screenshot inside lime viewfinder corners.
> Generous margins, nothing else.

**Check:** spelling is exact ("Take screenshot." / "Make a shot." / "shotr", all lowercase for the
wordmark). If the text comes out wrong, generate without text and add the text in Figma or Canva with
Inter Semibold.

## 4. Play Store feature graphic

File: `marketing/play/feature-graphic.png` (1024×500, no transparency)

**Nano Banana prompt:**
> [style block] A 1024×500 banner. Pure #08090A background. Center-right: a dark smartphone floating
> at a slight angle, its screen showing a blurred screenshot framed by four thin acid-lime #E4F222
> viewfinder corner brackets. Below the phone, a circular camera-shutter button: a thin white ring
> with a solid acid-lime disc inside. Left 40 percent of the banner is empty black for the title text,
> which will be added later. No text in the image.

Add "shotr: take screenshot, make a shot." on the left in Inter Semibold, white, afterwards.

## 5. Play Store screenshot backgrounds

Files: `marketing/play/bg-*.png` (1080×1920). Put real app screenshots on top in Figma/Canva.

**Nano Banana prompt:**
> [style block] A 1080×1920 vertical background. Pure #08090A with a very faint graphite vignette.
> Four thin acid-lime #E4F222 viewfinder corner brackets placed large around the middle of the frame,
> where a phone screenshot will be placed later, leaving a clean empty rectangle about 820×1640 in the
> center. Top 15 percent empty for a headline. Nothing else.

Headlines to put above each screenshot (white, Inter Semibold, from the app's own copy):
1. "Take screenshot. Make a shot."
2. "Share it from any app."
3. "Sorted on your phone."
4. "One tap. A draft in your voice."
5. "No streaks. No guilt."

## 6. Vertical social clip (Reels, Shorts, X)

File: `marketing/social/reel-01.mp4` (1080×1920, 8 s)

**Nano Banana still first (9:16):**
> [style block] Vertical 9:16. A smartphone standing upright on a black reflective surface, centered,
> its screen showing a blurred social post. Empty black above and below.

**Then the Veo prompt (image-to-video):**
> Keep the composition and colors. Second 0 to 2: four thin acid-lime viewfinder brackets slide in
> from outside the phone screen and lock onto the screen edges. Second 2: a quick soft white flash
> on the screen, like a screenshot being taken. Second 3 to 6: a dark rounded panel slides up from the
> bottom of the screen and a small acid-lime pill button pulses once. Second 6 to 8: slow push-in, calm.
> Smooth, precise motion with ease-out timing, no camera shake, no text, no hands, no people. Silent.

Put the music and captions on top in CapCut, or use the 21-second launch video in
`marketing/brag-output/` instead.

---

## Rules for anything new

- Black #08090A, one lime #E4F222 accent, neutrals only.
- Lime is for thin lines, small glows and the single key action, never a background.
- The viewfinder corners frame the one thing in focus, with only one framed thing per image.
- No people, no hands, no faces, no readable fake UI text, no other brand logos.
- Motion: slow, eased, precise. Things lock into place; nothing bounces or spins.
- Compress before committing: WebP quality 80 for images, H.264 CRF 24 for video, under 4 MB each.
