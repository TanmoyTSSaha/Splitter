-- Achievement catalog + per-user unlocks.

ALTER TABLE public.users
  ADD COLUMN IF NOT EXISTS timezone text NOT NULL DEFAULT 'Asia/Kolkata';

CREATE TABLE IF NOT EXISTS public.achievements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  slug text NOT NULL UNIQUE,
  name text NOT NULL,
  description text NOT NULL,
  icon_key text NOT NULL,
  rule_type text NOT NULL,
  rule_params jsonb NOT NULL DEFAULT '{}'::jsonb,
  sort_order int NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.user_achievements (
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  achievement_id uuid NOT NULL REFERENCES public.achievements (id) ON DELETE CASCADE,
  unlocked_at timestamptz NOT NULL DEFAULT now(),
  unlock_source text NOT NULL DEFAULT 'live'
    CHECK (unlock_source IN ('live', 'backfill')),
  celebration_shown boolean NOT NULL DEFAULT false,
  PRIMARY KEY (user_id, achievement_id)
);

CREATE INDEX IF NOT EXISTS idx_user_achievements_user
  ON public.user_achievements (user_id);

CREATE INDEX IF NOT EXISTS idx_user_achievements_pending_celebration
  ON public.user_achievements (user_id)
  WHERE celebration_shown = false AND unlock_source = 'live';

INSERT INTO public.achievements (slug, name, description, icon_key, rule_type, rule_params, sort_order)
VALUES
  ('first_trip', 'Explorer', 'Create your first trip.', 'explorer', 'trip_count', '{"threshold": 1}', 1),
  ('big_spender', 'Big Spender', 'Spend more than ₹1000 in total.', 'money_bag', 'lifetime_spend', '{"threshold": 1000}', 2),
  ('settlement_hero', 'Settlement Hero', 'Settle up 5 times.', 'handshake', 'settlement_count', '{"threshold": 5}', 3),
  ('early_bird', 'Early Bird', 'Add an expense before 8 AM.', 'sun', 'early_expense', '{"hour": 8}', 4),
  ('group_starter', 'Group Starter', 'Create your first group.', 'group', 'group_count', '{"threshold": 1}', 5),
  ('first_friend', 'Connector', 'Add your first friend.', 'friend', 'friend_count', '{"threshold": 1}', 6),
  ('first_split', 'First Split', 'Add your first group expense.', 'split', 'group_expense_count', '{"threshold": 1}', 7),
  ('budget_tracker', 'Budget Tracker', 'Log your first personal expense.', 'wallet', 'personal_expense_count', '{"threshold": 1}', 8),
  ('split_regular', 'Split Regular', 'Add 10 group expenses.', 'split_regular', 'group_expense_count', '{"threshold": 10}', 9),
  ('goal_setter', 'Goal Setter', 'Create your first financial goal.', 'goal', 'goal_count', '{"threshold": 1}', 10),
  ('loan_starter', 'Loan Starter', 'Create your first loan.', 'loan', 'loan_count', '{"threshold": 1}', 11),
  ('social_circle', 'Social Circle', 'Connect with 5 friends.', 'social', 'friend_count', '{"threshold": 5}', 12)
ON CONFLICT (slug) DO NOTHING;

ALTER TABLE public.achievements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_achievements ENABLE ROW LEVEL SECURITY;

CREATE POLICY achievements_read ON public.achievements
  FOR SELECT TO authenticated
  USING (is_active = true);

CREATE POLICY user_achievements_read ON public.user_achievements
  FOR SELECT TO authenticated
  USING (user_id = auth.uid());

ALTER PUBLICATION supabase_realtime ADD TABLE public.user_achievements;
