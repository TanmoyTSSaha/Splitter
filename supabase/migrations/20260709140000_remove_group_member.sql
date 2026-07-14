-- Admin remove another member (creator only; self-removal uses leave_group).

CREATE OR REPLACE FUNCTION public.remove_group_member(
  p_group_id uuid,
  p_member_id uuid
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF p_member_id = auth.uid() THEN
    RAISE EXCEPTION 'Use leave_group to remove yourself';
  END IF;

  IF NOT EXISTS (
    SELECT 1
    FROM public.groups g
    WHERE g.group_id = p_group_id
      AND g.created_by = auth.uid()
  ) THEN
    RAISE EXCEPTION 'Only the group creator can remove members';
  END IF;

  DELETE FROM public.group_members
  WHERE group_id = p_group_id
    AND user_id = p_member_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.remove_group_member(uuid, uuid) TO authenticated;
