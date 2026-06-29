-- Premium subscription flags synced from IAP (client sets; verify server-side in production).
ALTER TABLE users
  ADD COLUMN IF NOT EXISTS is_premium boolean NOT NULL DEFAULT false;

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS premium_expires_at timestamptz;

CREATE INDEX IF NOT EXISTS idx_users_is_premium ON users (is_premium)
  WHERE is_premium = true;
