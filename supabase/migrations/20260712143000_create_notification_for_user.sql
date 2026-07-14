-- Allow authenticated users to notify co-members / friends via SECURITY DEFINER RPC.
-- Direct INSERT is limited to user_id = auth.uid() by notifications_own RLS.

CREATE OR REPLACE FUNCTION public.create_notification_for_user(
  p_user_id uuid,
  p_type text,
  p_title text,
  p_body text DEFAULT NULL,
  p_metadata jsonb DEFAULT NULL
)
RETURNS uuid
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_id uuid;
  v_caller uuid := auth.uid();
  v_group_id uuid;
BEGIN
  IF v_caller IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  IF p_user_id IS NULL OR p_type IS NULL OR p_title IS NULL THEN
    RAISE EXCEPTION 'user_id, type, and title are required';
  END IF;

  IF p_user_id = v_caller THEN
    INSERT INTO public.notifications (user_id, type, title, body, metadata, is_read)
    VALUES (p_user_id, p_type, p_title, p_body, p_metadata, false)
    RETURNING id INTO v_id;
    RETURN v_id;
  END IF;

  v_group_id := NULLIF(p_metadata ->> 'group_id', '')::uuid;
  IF v_group_id IS NOT NULL
     AND public.is_group_member(v_group_id, v_caller)
     AND public.is_group_member(v_group_id, p_user_id) THEN
    INSERT INTO public.notifications (user_id, type, title, body, metadata, is_read)
    VALUES (p_user_id, p_type, p_title, p_body, p_metadata, false)
    RETURNING id INTO v_id;
    RETURN v_id;
  END IF;

  IF EXISTS (
    SELECT 1
    FROM public.friends f
    WHERE (f.user_id = v_caller AND f.friend_id = p_user_id)
       OR (f.user_id = p_user_id AND f.friend_id = v_caller)
  ) THEN
    INSERT INTO public.notifications (user_id, type, title, body, metadata, is_read)
    VALUES (p_user_id, p_type, p_title, p_body, p_metadata, false)
    RETURNING id INTO v_id;
    RETURN v_id;
  END IF;

  RAISE EXCEPTION 'Forbidden: cannot notify this user';
END;
$$;

GRANT EXECUTE ON FUNCTION public.create_notification_for_user(
  uuid, text, text, text, jsonb
) TO authenticated;
