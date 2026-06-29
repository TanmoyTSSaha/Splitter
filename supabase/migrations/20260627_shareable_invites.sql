-- Shareable invite links for friends and groups (deep link targets).
CREATE TABLE IF NOT EXISTS shareable_invites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token text UNIQUE NOT NULL,
  invite_type text NOT NULL CHECK (invite_type IN ('friend', 'group')),
  creator_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  group_id uuid REFERENCES groups (group_id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'used', 'revoked')),
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz DEFAULT (now() + interval '30 days')
);

CREATE INDEX IF NOT EXISTS idx_shareable_invites_token ON shareable_invites (token);
CREATE INDEX IF NOT EXISTS idx_shareable_invites_creator ON shareable_invites (creator_id);

ALTER TABLE shareable_invites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can create own invites"
  ON shareable_invites FOR INSERT
  WITH CHECK (auth.uid() = creator_id);

CREATE POLICY "Anyone authenticated can read active invites by token"
  ON shareable_invites FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Creator can update own invites"
  ON shareable_invites FOR UPDATE
  USING (auth.uid() = creator_id);
