-- RPC functions, auth trigger, and RLS policies for Splitr.

-- ─── Auth: auto-create public.users profile ──────────────────────────────────
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.users (
    user_id,
    user_email,
    user_name,
    firstname,
    lastname,
    created_at
  ) VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data ->> 'user_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data ->> 'first_name', NEW.raw_user_meta_data ->> 'firstname', ''),
    COALESCE(NEW.raw_user_meta_data ->> 'last_name', NEW.raw_user_meta_data ->> 'lastname', ''),
    now()
  )
  ON CONFLICT (user_id) DO UPDATE SET
    user_email = EXCLUDED.user_email,
    user_name = COALESCE(public.users.user_name, EXCLUDED.user_name);
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ─── Helper: is group member ─────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.is_group_member(p_group_id uuid, p_user_id uuid DEFAULT auth.uid())
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.group_members
    WHERE group_id = p_group_id AND user_id = p_user_id
  );
$$;

-- ─── RPC: create group with creator as member ────────────────────────────────
CREATE OR REPLACE FUNCTION public.create_group_with_member(p_group_name text)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_group_id uuid := gen_random_uuid();
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  INSERT INTO public.groups (group_id, group_name, created_by, group_balance)
  VALUES (v_group_id, p_group_name, v_user_id, '[]'::jsonb);

  INSERT INTO public.group_members (group_id, user_id)
  VALUES (v_group_id, v_user_id);

  RETURN jsonb_build_object('group_id', v_group_id);
END;
$$;

-- ─── RPC: add members to group ───────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.add_group_members(
  p_group_id uuid,
  p_user_ids uuid[]
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_member uuid;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF NOT public.is_group_member(p_group_id, v_user_id) THEN
    RAISE EXCEPTION 'Not a group member';
  END IF;

  FOREACH v_member IN ARRAY p_user_ids LOOP
    INSERT INTO public.group_members (group_id, user_id)
    VALUES (p_group_id, v_member)
    ON CONFLICT DO NOTHING;
  END LOOP;
END;
$$;

-- ─── RPC: create trip group ──────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.create_trip_with_member(
  p_trip_name text,
  p_destination text,
  p_start_date timestamptz,
  p_end_date timestamptz
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_group_id uuid := gen_random_uuid();
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  INSERT INTO public.groups (group_id, group_name, created_by, group_balance)
  VALUES (v_group_id, p_trip_name, v_user_id, '[]'::jsonb);

  INSERT INTO public.group_members (group_id, user_id)
  VALUES (v_group_id, v_user_id);

  INSERT INTO public.trip_metadata (
    group_id, trip_name, destination, start_date, end_date, created_by, member_ids
  ) VALUES (
    v_group_id, p_trip_name, p_destination, p_start_date, p_end_date, v_user_id,
    jsonb_build_array(v_user_id::text)
  );

  RETURN jsonb_build_object('group_id', v_group_id);
END;
$$;

-- ─── RPC: respond to group invite ────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.respond_to_group_invite(
  p_invite_id uuid,
  p_accept boolean
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_user_id uuid := auth.uid();
  v_invite record;
BEGIN
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  SELECT * INTO v_invite
  FROM public.group_invites
  WHERE id = p_invite_id AND invited_user_id = v_user_id AND status = 'pending';

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Invite not found';
  END IF;

  IF p_accept THEN
    UPDATE public.group_invites SET status = 'accepted' WHERE id = p_invite_id;
    INSERT INTO public.group_members (group_id, user_id)
    VALUES (v_invite.group_id, v_user_id)
    ON CONFLICT DO NOTHING;
  ELSE
    UPDATE public.group_invites SET status = 'declined' WHERE id = p_invite_id;
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_group_with_member(text) TO authenticated;
GRANT EXECUTE ON FUNCTION public.add_group_members(uuid, uuid[]) TO authenticated;
GRANT EXECUTE ON FUNCTION public.create_trip_with_member(text, text, timestamptz, timestamptz) TO authenticated;
GRANT EXECUTE ON FUNCTION public.respond_to_group_invite(uuid, boolean) TO authenticated;
GRANT EXECUTE ON FUNCTION public.is_group_member(uuid, uuid) TO authenticated;

-- ─── RLS ─────────────────────────────────────────────────────────────────────
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_transaction ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.personal_transaction ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.master_product_category ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_custom_category ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.personal_custom_category ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trip_metadata ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.friends ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shareable_invites ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_reactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.activity_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reminder_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.group_wishlists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.wishlist_upvotes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.financial_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.goal_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.loans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feature_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.feature_request_votes ENABLE ROW LEVEL SECURITY;

-- users
CREATE POLICY users_select ON public.users FOR SELECT TO authenticated USING (true);
CREATE POLICY users_insert_own ON public.users FOR INSERT TO authenticated WITH CHECK (auth.uid() = user_id);
CREATE POLICY users_update_own ON public.users FOR UPDATE TO authenticated USING (auth.uid() = user_id);

-- groups
CREATE POLICY groups_select_member ON public.groups FOR SELECT TO authenticated
  USING (public.is_group_member(group_id));
CREATE POLICY groups_update_member ON public.groups FOR UPDATE TO authenticated
  USING (public.is_group_member(group_id));

-- group_members
CREATE POLICY group_members_select ON public.group_members FOR SELECT TO authenticated
  USING (public.is_group_member(group_id));
CREATE POLICY group_members_insert_self ON public.group_members FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid() OR public.is_group_member(group_id));

-- group_transaction
CREATE POLICY group_tx_select ON public.group_transaction FOR SELECT TO authenticated
  USING (public.is_group_member(group_id));
CREATE POLICY group_tx_insert ON public.group_transaction FOR INSERT TO authenticated
  WITH CHECK (public.is_group_member(group_id));

-- personal_transaction
CREATE POLICY personal_tx_all ON public.personal_transaction FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- categories
CREATE POLICY master_cat_read ON public.master_product_category FOR SELECT TO authenticated USING (true);
CREATE POLICY group_cat_all ON public.group_custom_category FOR ALL TO authenticated
  USING (public.is_group_member(group_id)) WITH CHECK (public.is_group_member(group_id));
CREATE POLICY personal_cat_all ON public.personal_custom_category FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- trips
CREATE POLICY trip_meta_select ON public.trip_metadata FOR SELECT TO authenticated
  USING (public.is_group_member(group_id));

-- friends
CREATE POLICY friends_select ON public.friends FOR SELECT TO authenticated
  USING (user_id = auth.uid() OR friend_id = auth.uid());
CREATE POLICY friends_insert ON public.friends FOR INSERT TO authenticated
  WITH CHECK (user_id = auth.uid());
CREATE POLICY friends_update ON public.friends FOR UPDATE TO authenticated
  USING (user_id = auth.uid() OR friend_id = auth.uid());

-- group_invites
CREATE POLICY group_invites_select ON public.group_invites FOR SELECT TO authenticated
  USING (invited_user_id = auth.uid() OR invited_by = auth.uid() OR public.is_group_member(group_id));
CREATE POLICY group_invites_insert ON public.group_invites FOR INSERT TO authenticated
  WITH CHECK (invited_by = auth.uid() AND public.is_group_member(group_id));

-- shareable_invites
CREATE POLICY shareable_invites_select ON public.shareable_invites FOR SELECT TO authenticated USING (true);
CREATE POLICY shareable_invites_insert ON public.shareable_invites FOR INSERT TO authenticated
  WITH CHECK (creator_id = auth.uid());
CREATE POLICY shareable_invites_update ON public.shareable_invites FOR UPDATE TO authenticated
  USING (creator_id = auth.uid());

-- activity
CREATE POLICY activity_reactions_all ON public.activity_reactions FOR ALL TO authenticated USING (true) WITH CHECK (user_id = auth.uid());
CREATE POLICY activity_comments_select ON public.activity_comments FOR SELECT TO authenticated USING (true);
CREATE POLICY activity_comments_insert ON public.activity_comments FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY activity_comments_delete ON public.activity_comments FOR DELETE TO authenticated USING (user_id = auth.uid());

-- notifications
CREATE POLICY notifications_own ON public.notifications FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- reminder_settings
CREATE POLICY reminder_settings_own ON public.reminder_settings FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- wishlists
CREATE POLICY wishlists_select ON public.group_wishlists FOR SELECT TO authenticated
  USING (public.is_group_member(group_id));
CREATE POLICY wishlists_insert ON public.group_wishlists FOR INSERT TO authenticated
  WITH CHECK (public.is_group_member(group_id) AND added_by = auth.uid());
CREATE POLICY wishlists_update ON public.group_wishlists FOR UPDATE TO authenticated
  USING (public.is_group_member(group_id));
CREATE POLICY wishlists_delete ON public.group_wishlists FOR DELETE TO authenticated
  USING (added_by = auth.uid());
CREATE POLICY wishlist_upvotes_all ON public.wishlist_upvotes FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- goals
CREATE POLICY goals_own ON public.financial_goals FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());
CREATE POLICY goal_tx_via_goal ON public.goal_transactions FOR ALL TO authenticated
  USING (EXISTS (
    SELECT 1 FROM public.financial_goals g
    WHERE g.id = goal_id AND g.user_id = auth.uid()
  ))
  WITH CHECK (EXISTS (
    SELECT 1 FROM public.financial_goals g
    WHERE g.id = goal_id AND g.user_id = auth.uid()
  ));

-- loans
CREATE POLICY loans_participant ON public.loans FOR ALL TO authenticated
  USING (lender_id = auth.uid() OR borrower_id = auth.uid())
  WITH CHECK (lender_id = auth.uid() OR borrower_id = auth.uid());

-- feature requests
CREATE POLICY feature_requests_read ON public.feature_requests FOR SELECT TO authenticated USING (true);
CREATE POLICY feature_requests_insert ON public.feature_requests FOR INSERT TO authenticated WITH CHECK (user_id = auth.uid());
CREATE POLICY feature_votes_all ON public.feature_request_votes FOR ALL TO authenticated
  USING (user_id = auth.uid()) WITH CHECK (user_id = auth.uid());

-- Realtime publication for key tables
ALTER PUBLICATION supabase_realtime ADD TABLE public.group_transaction;
ALTER PUBLICATION supabase_realtime ADD TABLE public.groups;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
