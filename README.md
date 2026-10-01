# shotr

**Take screenshot. Make a shot.** People take screenshots they never act on. shotr turns each one
into the thing they meant to do: an X/LinkedIn post, a cold email, a build note or learning takeaways,
in their own voice.

| Path | What |
|---|---|
| `SPEC.md` | Product spec: screens, logic, flows, edge cases, tech. Decisions log at the top |
| `DESIGN.md` | Design system. Every new screen is checked against it |
| `app/` | Flutter app, Android first, iOS from the same code. See `app/README.md` |
| `worker/` | Cloudflare Worker: auth, quota, makes via OpenRouter, waitlist. See `worker/README.md` |
| `web/` | Landing page with the launch video and email waitlist (static, deploy to Cloudflare Pages) |
| `marketing/` | Promo loop (vertical) and the 21s launch video made with the brag skill |

Design canvas (all screens, promo, landing): https://claude.ai/artifact/7wMikfoK3Ptq7fGhjyd9jX

## Quick start

```bash
# app
cd app && flutter pub get && dart run build_runner build && flutter test && flutter run

# worker
cd worker && npm install && npm test && npm run dev

# landing page
npx wrangler pages deploy web --project-name shotr-web
```

Pricing: Free (unlimited saving and sorting, 5 makes) and shotr Pro at $19/month.
