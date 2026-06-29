-- SplitO initial schema for a fresh Supabase project.
-- Core tables, RPCs, RLS, seed categories, and auth profile trigger.

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ─── Users ───────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.users (
  user_id uuid PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  user_name text,
  firstname text,
  lastname text,
  user_email text,
  phone text,
  currency text NOT NULL DEFAULT 'INR',
  total_spent numeric NOT NULL DEFAULT 0,
  total_received numeric NOT NULL DEFAULT 0,
  profile_picture_url text,
  is_premium boolean NOT NULL DEFAULT false,
  premium_expires_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- ─── Groups ──────────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.groups (
  group_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_name text NOT NULL,
  group_balance jsonb NOT NULL DEFAULT '[]'::jsonb,
  created_by uuid REFERENCES auth.users (id) ON DELETE SET NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_on timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.group_members (
  group_id uuid NOT NULL REFERENCES public.groups (group_id) ON DELETE CASCADE,
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  joined_at timestamptz NOT NULL DEFAULT now(),
  PRIMARY KEY (group_id, user_id)
);

CREATE INDEX IF NOT EXISTS idx_group_members_user ON public.group_members (user_id);

-- ─── Transactions ────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.group_transaction (
  transaction_id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  transaction_group_id text NOT NULL,
  group_id uuid NOT NULL REFERENCES public.groups (group_id) ON DELETE CASCADE,
  paid_by uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  shared_with uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  total_transaction_amount numeric NOT NULL DEFAULT 0,
  shared_transaction_amount numeric NOT NULL DEFAULT 0,
  shared_percentage numeric NOT NULL DEFAULT 0,
  self_share_amount numeric NOT NULL DEFAULT 0,
  self_share_percentage numeric NOT NULL DEFAULT 0,
  sharing_type text NOT NULL DEFAULT 'evenly',
  category text,
  description text,
  transaction_note text,
  transaction_photo text,
  currency text NOT NULL DEFAULT 'INR',
  exchange_rate_to_inr numeric NOT NULL DEFAULT 1,
  is_settled_up boolean NOT NULL DEFAULT false,
  transaction_date timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_group_transaction_group
  ON public.group_transaction (group_id, transaction_date DESC);

CREATE TABLE IF NOT EXISTS public.personal_transaction (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  amount numeric NOT NULL,
  transaction_description text,
  category text,
  transaction_date timestamptz NOT NULL DEFAULT now(),
  payment_method text,
  currency text NOT NULL DEFAULT 'INR',
  exchange_rate_to_inr numeric NOT NULL DEFAULT 1
);

CREATE INDEX IF NOT EXISTS idx_personal_transaction_user
  ON public.personal_transaction (user_id, transaction_date DESC);

-- ─── Categories ──────────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.master_product_category (
  category text PRIMARY KEY,
  category_logo text
);

CREATE TABLE IF NOT EXISTS public.group_custom_category (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  group_id uuid NOT NULL REFERENCES public.groups (group_id) ON DELETE CASCADE,
  category text NOT NULL,
  icon_url text,
  UNIQUE (group_id, category)
);

CREATE TABLE IF NOT EXISTS public.personal_custom_category (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  category text NOT NULL,
  icon_url text,
  UNIQUE (user_id, category)
);

INSERT INTO public.master_product_category (category, category_logo) VALUES
  ('Food', 'food'),
  ('Transport', 'transport'),
  ('Shopping', 'shopping'),
  ('Entertainment', 'entertainment'),
  ('Bills', 'bills'),
  ('Travel', 'travel'),
  ('Health', 'health'),
  ('Education', 'education'),
  ('Rent', 'rent'),
  ('Other', 'other')
ON CONFLICT (category) DO NOTHING;
