-- Trip ledger currency for multi-currency travel (Pro-gated in app).

ALTER TABLE public.trip_metadata
  ADD COLUMN IF NOT EXISTS trip_currency text NOT NULL DEFAULT 'INR';

CREATE OR REPLACE FUNCTION public.create_trip_with_member(
  p_trip_name text,
  p_destination text,
  p_start_date timestamptz,
  p_end_date timestamptz,
  p_trip_currency text DEFAULT 'INR'
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
    group_id, trip_name, destination, start_date, end_date, created_by, member_ids, trip_currency
  ) VALUES (
    v_group_id, p_trip_name, p_destination, p_start_date, p_end_date, v_user_id,
    jsonb_build_array(v_user_id::text), COALESCE(NULLIF(trim(p_trip_currency), ''), 'INR')
  );

  RETURN jsonb_build_object('group_id', v_group_id);
END;
$$;
