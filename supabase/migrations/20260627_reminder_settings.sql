-- Per-user per-group reminder preferences.
CREATE TABLE IF NOT EXISTS reminder_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  group_id uuid NOT NULL REFERENCES groups (group_id) ON DELETE CASCADE,
  cadence text NOT NULL DEFAULT 'weekly',
  tone text NOT NULL DEFAULT 'friendly',
  muted_member_ids jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, group_id)
);

CREATE INDEX IF NOT EXISTS idx_reminder_settings_user_group
  ON reminder_settings (user_id, group_id);

ALTER TABLE reminder_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users manage own reminder settings"
  ON reminder_settings FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);
