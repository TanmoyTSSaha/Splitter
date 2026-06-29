-- SplitO feature tables: trips, friends, invites, social, goals, loans, wishlists.

CREATE TABLE IF NOT EXISTS public.trip_metadata (
  group_id uuid PRIMARY KEY REFERENCES public.groups (group_id) ON DELETE CASCADE,
  trip_name text NOT NULL,
  destination text,
  start_date timestamptz NOT NULL,
  end_date timestamptz NOT NULL,
  created_by uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  member_ids jsonb NOT NULL DEFAULT '[]'::jsonb,
  cover_image_url text
);

CREATE TABLE IF NOT EXISTS public.friends (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  friend_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'rejected')),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, friend_id)
);

CREATE INDEX IF NOT EXISTS idx_friends_user ON public.friends (user_id);
CREATE INDEX IF NOT EXISTS idx_friends_friend ON public.friends (friend_id);

CREATE TABLE IF NOT EXISTS public.group_invites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid NOT NULL REFERENCES public.groups (group_id) ON DELETE CASCADE,
  invited_by uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  invited_user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'declined')),
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (group_id, invited_user_id)
);

CREATE TABLE IF NOT EXISTS public.shareable_invites (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token text UNIQUE NOT NULL,
  invite_type text NOT NULL CHECK (invite_type IN ('friend', 'group')),
  creator_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  group_id uuid REFERENCES public.groups (group_id) ON DELETE CASCADE,
  status text NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'used', 'revoked')),
  created_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz DEFAULT (now() + interval '30 days')
);

CREATE INDEX IF NOT EXISTS idx_shareable_invites_token ON public.shareable_invites (token);

CREATE TABLE IF NOT EXISTS public.activity_reactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id text NOT NULL,
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  emoji text NOT NULL,
  user_name text,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (activity_id, user_id, emoji)
);

CREATE TABLE IF NOT EXISTS public.activity_comments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  activity_id text NOT NULL,
  group_id uuid NOT NULL REFERENCES public.groups (group_id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  user_name text,
  body text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_activity_comments_activity
  ON public.activity_comments (activity_id, created_at);

CREATE TABLE IF NOT EXISTS public.notifications (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  type text NOT NULL,
  title text NOT NULL,
  body text,
  metadata jsonb,
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_user
  ON public.notifications (user_id, created_at DESC);

CREATE TABLE IF NOT EXISTS public.reminder_settings (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  group_id uuid NOT NULL REFERENCES public.groups (group_id) ON DELETE CASCADE,
  cadence text NOT NULL DEFAULT 'weekly',
  tone text NOT NULL DEFAULT 'friendly',
  muted_member_ids jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, group_id)
);

CREATE TABLE IF NOT EXISTS public.group_wishlists (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid NOT NULL REFERENCES public.groups (group_id) ON DELETE CASCADE,
  title text NOT NULL,
  estimated_amount numeric,
  added_by uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  is_added_to_expenses boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.wishlist_upvotes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  wishlist_item_id uuid NOT NULL REFERENCES public.group_wishlists (id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (wishlist_item_id, user_id)
);

CREATE TABLE IF NOT EXISTS public.financial_goals (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  title text NOT NULL,
  target_amount numeric NOT NULL DEFAULT 0,
  current_amount numeric NOT NULL DEFAULT 0,
  deadline timestamptz,
  status text NOT NULL DEFAULT 'active',
  icon text,
  color_hex text,
  icon_key text,
  smart_recommendation_id text,
  estimated_completion_date timestamptz,
  description text,
  goal_type text,
  currency text NOT NULL DEFAULT 'INR',
  exchange_rate_to_inr numeric NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.goal_transactions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  goal_id uuid NOT NULL REFERENCES public.financial_goals (id) ON DELETE CASCADE,
  amount numeric NOT NULL,
  type text NOT NULL CHECK (type IN ('deposit', 'withdraw')),
  note text,
  currency text NOT NULL DEFAULT 'INR',
  exchange_rate_to_inr numeric NOT NULL DEFAULT 1,
  transaction_date timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.loans (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  lender_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  borrower_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  principal_amount numeric NOT NULL,
  interest_rate numeric NOT NULL DEFAULT 0,
  interest_type text NOT NULL DEFAULT 'simple',
  interest_period text NOT NULL DEFAULT 'monthly',
  start_date timestamptz NOT NULL,
  due_date timestamptz,
  status text NOT NULL DEFAULT 'pending',
  repayment_amount numeric NOT NULL DEFAULT 0,
  duration integer,
  duration_unit text,
  repayment_start_date timestamptz,
  repayment_end_date timestamptz,
  currency text NOT NULL DEFAULT 'INR',
  exchange_rate_to_inr numeric NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.feature_requests (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  category text,
  priority text,
  vote_count integer NOT NULL DEFAULT 1,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.feature_request_votes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  request_id uuid NOT NULL REFERENCES public.feature_requests (id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (request_id, user_id)
);

-- View for settle-up health queries (balances stored as JSON on groups).
CREATE OR REPLACE VIEW public.group_balance AS
SELECT
  g.group_id,
  (elem ->> 'donor_id')::uuid AS donor_id,
  (elem ->> 'receiver_id')::uuid AS receiver_id,
  (elem ->> 'amount')::numeric AS amount
FROM public.groups g
CROSS JOIN LATERAL jsonb_array_elements(
  CASE
    WHEN jsonb_typeof(g.group_balance) = 'array' THEN g.group_balance
    ELSE '[]'::jsonb
  END
) AS elem
WHERE (elem ->> 'donor_id') IS NOT NULL
  AND (elem ->> 'receiver_id') IS NOT NULL;
