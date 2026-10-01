-- Usage + entitlement records (SPEC tech: Cloudflare D1). No screenshots, no images.

CREATE TABLE IF NOT EXISTS users (
  uid            TEXT PRIMARY KEY,           -- Firebase UID (also the RevenueCat app user ID)
  created_at     INTEGER NOT NULL,
  is_pro         INTEGER NOT NULL DEFAULT 0,
  pro_expires_at INTEGER,                    -- ms epoch, from RevenueCat
  free_used      INTEGER NOT NULL DEFAULT 0  -- successful free makes
);

-- One row per successful, charged make. Failed or empty responses are never written.
CREATE TABLE IF NOT EXISTS usage (
  id         TEXT PRIMARY KEY,
  uid        TEXT NOT NULL,
  shot_id    TEXT NOT NULL,
  kind       TEXT NOT NULL,                  -- make | regenerate
  output     TEXT NOT NULL,
  month      TEXT NOT NULL,                  -- YYYY-MM for the fair-use cap
  created_at INTEGER NOT NULL
);
CREATE INDEX IF NOT EXISTS usage_uid_month ON usage (uid, month);

-- 1 free regenerate per shot.
CREATE TABLE IF NOT EXISTS shot_regens (
  uid     TEXT NOT NULL,
  shot_id TEXT NOT NULL,
  used    INTEGER NOT NULL DEFAULT 0,
  PRIMARY KEY (uid, shot_id)
);

-- Draft IDs only (no content) so reports can point at a make.
CREATE TABLE IF NOT EXISTS drafts (
  id         TEXT PRIMARY KEY,
  uid        TEXT NOT NULL,
  shot_id    TEXT NOT NULL,
  output     TEXT NOT NULL,
  model      TEXT NOT NULL,
  created_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS reports (
  id         TEXT PRIMARY KEY,
  uid        TEXT NOT NULL,
  draft_id   TEXT NOT NULL,
  reason     TEXT NOT NULL,
  created_at INTEGER NOT NULL
);

-- "Your skill.md": system prompts per shot type, editable without an app update.
-- Empty table = built-in defaults from src/prompts.ts.
CREATE TABLE IF NOT EXISTS prompts (
  type       TEXT PRIMARY KEY,               -- post | email | buildNote | takeaways | classify
  system     TEXT NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS waitlist (
  email      TEXT PRIMARY KEY,
  created_at INTEGER NOT NULL,
  source     TEXT,
  referrer   TEXT
);
