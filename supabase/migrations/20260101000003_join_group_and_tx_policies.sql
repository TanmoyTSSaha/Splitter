-- Allow users to join a group via shareable invite (self-join).
CREATE OR REPLACE FUNCTION public.join_group_as_member(p_group_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid := auth.uid();
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;
  INSERT INTO public.group_members (group_id, user_id)
  VALUES (p_group_id, v_user_id)
  ON CONFLICT DO NOTHING;
END;
$$;

GRANT EXECUTE ON FUNCTION public.join_group_as_member(uuid) TO authenticated;

CREATE POLICY group_tx_update ON public.group_transaction FOR UPDATE TO authenticated
  USING (public.is_group_member(group_id)) WITH CHECK (public.is_group_member(group_id));

CREATE POLICY group_tx_delete ON public.group_transaction FOR DELETE TO authenticated
  USING (public.is_group_member(group_id));
