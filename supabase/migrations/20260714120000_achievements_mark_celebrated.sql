-- Mark achievement celebration overlay as shown.

CREATE OR REPLACE FUNCTION public.mark_achievement_celebrated(p_achievement_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.uid() IS NULL THEN
    RAISE EXCEPTION 'Not authenticated';
  END IF;

  UPDATE public.user_achievements
  SET celebration_shown = true
  WHERE user_id = auth.uid()
    AND achievement_id = p_achievement_id;
END;
$$;

GRANT EXECUTE ON FUNCTION public.mark_achievement_celebrated(uuid) TO authenticated;
