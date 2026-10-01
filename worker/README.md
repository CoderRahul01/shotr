# shotr Worker (Cloudflare + Hono)

The only server. It verifies the Firebase token on every call, checks Pro status and quota in D1,
calls OpenRouter with the right prompt ("your skill.md"), and takes waitlist emails from the landing page.
No images are stored. Draft text isn't stored either: only IDs, for reports.

## Endpoints

| Method | Path | Auth | What |
|---|---|---|---|
| GET | `/health` | none | uptime |
| POST | `/v1/waitlist` | none (CORS: landing origins) | `{email, source}` |
| POST | `/v1/revenuecat/webhook` | RevenueCat header | keeps `users.is_pro` in sync, refunds lock makes |
| GET | `/v1/me` | Firebase | `{is_pro, free_makes_left, free_makes_total, monthly_makes_left}` |
| POST | `/v1/classify` | Firebase | cloud sorting fallback |
| POST | `/v1/make` | Firebase | make / regenerate / tweak. 402 = paywall |
| POST | `/v1/vision` | Firebase, Pro | one-line description of a low-text screenshot |
| POST | `/v1/report` | Firebase | report an AI draft |
| DELETE | `/v1/account` | Firebase | delete every record for the user |

Usage rules live in `src/quota.ts` (tested): 5 free makes, Pro monthly fair-use cap, tweaks free,
1 free regenerate per shot, failed or junk drafts never charged (retried once silently).
Screenshot text is wrapped in `<screenshot_text>` and escaped so it can't instruct the model (`src/prompts.ts`).

## Setup

```bash
npm install
npx wrangler d1 create shotr            # paste database_id into wrangler.toml
npm run db:init                          # apply schema.sql
npx wrangler secret put OPENROUTER_API_KEY
npx wrangler secret put REVENUECAT_WEBHOOK_AUTH
# set FIREBASE_PROJECT_ID and check the model slugs in wrangler.toml against openrouter.ai/models
npm run deploy
```

Local: `npm run db:init:local && npm run dev` (put secrets in `.dev.vars`).

## Changing prompts without an app update

```sql
INSERT INTO prompts (type, system, updated_at) VALUES ('post', '...new prompt...', unixepoch() * 1000)
ON CONFLICT(type) DO UPDATE SET system = excluded.system, updated_at = excluded.updated_at;
```

Types: `post`, `email`, `buildNote`, `takeaways`, `classify`. Keep the data-only rule from `src/prompts.ts` in any rewrite.

## Pro fair-use cap

`PRO_MONTHLY_MAKES` is a placeholder (300). SPEC: set it after measuring the real cost per make.
