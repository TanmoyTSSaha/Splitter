-- Allow senders to cancel their own pending friend requests.
CREATE POLICY friends_delete ON public.friends
  FOR DELETE TO authenticated
  USING (user_id = auth.uid() AND status = 'pending');
