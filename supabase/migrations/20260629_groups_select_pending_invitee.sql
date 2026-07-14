-- Allow invited users to read group name before they join.
CREATE POLICY groups_select_pending_invitee ON public.groups
  FOR SELECT TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.group_invites gi
      WHERE gi.group_id = groups.group_id
        AND gi.invited_user_id = auth.uid()
        AND gi.status = 'pending'
    )
  );
