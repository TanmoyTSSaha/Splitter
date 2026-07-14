-- User UPI accounts for peer settle-up (multiple VPAs per user with bank alias).

CREATE TABLE IF NOT EXISTS public.user_upi_accounts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES public.users (user_id) ON DELETE CASCADE,
  vpa text NOT NULL,
  bank_alias text NOT NULL,
  is_primary boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT user_upi_accounts_user_vpa_unique UNIQUE (user_id, vpa)
);

CREATE INDEX IF NOT EXISTS idx_user_upi_accounts_user_id
  ON public.user_upi_accounts (user_id);

ALTER TABLE public.user_upi_accounts ENABLE ROW LEVEL SECURITY;

-- Own rows: full access
CREATE POLICY user_upi_accounts_select_own ON public.user_upi_accounts
  FOR SELECT TO authenticated
  USING (auth.uid() = user_id);

CREATE POLICY user_upi_accounts_insert_own ON public.user_upi_accounts
  FOR INSERT TO authenticated
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY user_upi_accounts_update_own ON public.user_upi_accounts
  FOR UPDATE TO authenticated
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY user_upi_accounts_delete_own ON public.user_upi_accounts
  FOR DELETE TO authenticated
  USING (auth.uid() = user_id);

-- Co-group members can read payee VPAs for settle-up picker
CREATE POLICY user_upi_accounts_select_co_member ON public.user_upi_accounts
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.group_members gm_self
      JOIN public.group_members gm_other
        ON gm_self.group_id = gm_other.group_id
      WHERE gm_self.user_id = auth.uid()
        AND gm_other.user_id = user_upi_accounts.user_id
    )
  );
