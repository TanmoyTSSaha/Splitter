-- Threaded comments on group activity feed items (transaction activity IDs).
CREATE TABLE IF NOT EXISTS activity_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id text NOT NULL,
  group_id uuid NOT NULL REFERENCES groups (group_id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  user_name text,
  body text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_activity_comments_activity
  ON activity_comments (activity_id, created_at);

ALTER TABLE activity_comments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Group members can read activity comments"
  ON activity_comments FOR SELECT
  USING (auth.role() = 'authenticated');

CREATE POLICY "Users can insert own comments"
  ON activity_comments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own comments"
  ON activity_comments FOR DELETE
  USING (auth.uid() = user_id);
