-- Production schema: income flag, archived groups, budgets, public share links.

ALTER TABLE public.personal_transaction
  ADD COLUMN IF NOT EXISTS is_credit boolean NOT NULL DEFAULT false;

ALTER TABLE public.groups
  ADD COLUMN IF NOT EXISTS is_archived boolean NOT NULL DEFAULT false;

CREATE TABLE IF NOT EXISTS public.personal_budgets (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  category text,
  monthly_limit numeric NOT NULL,
  alert_threshold numeric NOT NULL DEFAULT 0.9,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, category)
);

CREATE TABLE IF NOT EXISTS public.public_share_links (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  token text NOT NULL UNIQUE,
  payload jsonb NOT NULL,
  created_by uuid REFERENCES auth.users (id) ON DELETE SET NULL,
  expires_at timestamptz,
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_public_share_links_token
  ON public.public_share_links (token);

ALTER TABLE public.personal_budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.public_share_links ENABLE ROW LEVEL SECURITY;

CREATE POLICY personal_budgets_own ON public.personal_budgets
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY share_links_insert ON public.public_share_links
  FOR INSERT TO authenticated
  WITH CHECK (created_by = auth.uid());

CREATE POLICY share_links_read_own ON public.public_share_links
  FOR SELECT TO authenticated
  USING (created_by = auth.uid());

-- Anonymous read via token (for web summary links).
CREATE POLICY share_links_public_read ON public.public_share_links
  FOR SELECT TO anon
  USING (expires_at IS NULL OR expires_at > now());

-- Leave group: remove member row (creator cannot leave if sole admin — app enforces).
CREATE OR REPLACE FUNCTION public.leave_group(p_group_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  DELETE FROM public.group_members
  WHERE group_id = p_group_id AND user_id = auth.uid();
END;
$$;

GRANT EXECUTE ON FUNCTION public.leave_group(uuid) TO authenticated;
