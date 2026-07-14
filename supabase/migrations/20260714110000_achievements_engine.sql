-- Achievement evaluators, triggers, and silent backfill.

CREATE OR REPLACE FUNCTION public.achievement_trip_count(p_user_id uuid)
RETURNS integer
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT COUNT(*)::integer FROM public.trip_metadata WHERE created_by = p_user_id;
$$;

CREATE OR REPLACE FUNCTION public.achievement_settlement_count(p_user_id uuid)
RETURNS integer
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT COUNT(*)::integer
  FROM public.group_transaction gt
  WHERE gt.sharing_type = 'settlement'
    AND (gt.paid_by = p_user_id OR gt.shared_with = p_user_id);
$$;

-- Mirrors TransactionService.getLifetimeStats totalSpent + INR normalization.
CREATE OR REPLACE FUNCTION public.achievement_lifetime_spend_inr(p_user_id uuid)
RETURNS numeric
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT COALESCE((
    SELECT SUM(pt.amount * COALESCE(pt.exchange_rate_to_inr, 1))
    FROM public.personal_transaction pt
    WHERE pt.user_id = p_user_id
  ), 0)
  + COALESCE((
    SELECT SUM(gt.shared_transaction_amount * COALESCE(gt.exchange_rate_to_inr, 1))
    FROM public.group_transaction gt
    WHERE gt.shared_with = p_user_id
      AND gt.category IS DISTINCT FROM 'Settlement'
  ), 0);
$$;

CREATE OR REPLACE FUNCTION public.achievement_group_expense_count(p_user_id uuid)
RETURNS integer
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT COUNT(DISTINCT gt.transaction_group_id)::integer
  FROM public.group_transaction gt
  WHERE gt.paid_by = p_user_id
    AND gt.sharing_type IS DISTINCT FROM 'settlement'
    AND gt.category IS DISTINCT FROM 'Settlement';
$$;

CREATE OR REPLACE FUNCTION public.achievement_personal_expense_count(p_user_id uuid)
RETURNS integer
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT COUNT(*)::integer
  FROM public.personal_transaction
  WHERE user_id = p_user_id;
$$;

CREATE OR REPLACE FUNCTION public.achievement_group_count(p_user_id uuid)
RETURNS integer
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT COUNT(*)::integer
  FROM public.groups
  WHERE created_by = p_user_id;
$$;

CREATE OR REPLACE FUNCTION public.achievement_friend_count(p_user_id uuid)
RETURNS integer
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT COUNT(*)::integer
  FROM public.friends f
  WHERE f.status = 'accepted'
    AND (f.user_id = p_user_id OR f.friend_id = p_user_id);
$$;

CREATE OR REPLACE FUNCTION public.achievement_goal_count(p_user_id uuid)
RETURNS integer
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT COUNT(*)::integer
  FROM public.financial_goals
  WHERE user_id = p_user_id;
$$;

CREATE OR REPLACE FUNCTION public.achievement_loan_count(p_user_id uuid)
RETURNS integer
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT COUNT(*)::integer
  FROM public.loans
  WHERE created_by = p_user_id;
$$;

CREATE OR REPLACE FUNCTION public.achievement_has_early_expense(p_user_id uuid, p_hour integer)
RETURNS boolean
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1
    FROM public.group_transaction gt
    JOIN public.users u ON u.user_id = p_user_id
    WHERE gt.paid_by = p_user_id
      AND gt.sharing_type IS DISTINCT FROM 'settlement'
      AND gt.category IS DISTINCT FROM 'Settlement'
      AND EXTRACT(
        HOUR FROM gt.transaction_date AT TIME ZONE COALESCE(u.timezone, 'Asia/Kolkata')
      ) < p_hour
  );
$$;

CREATE OR REPLACE FUNCTION public.grant_achievement(
  p_user_id uuid,
  p_achievement_id uuid,
  p_unlock_source text DEFAULT 'live'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF p_user_id IS NULL OR p_achievement_id IS NULL THEN
    RETURN;
  END IF;

  INSERT INTO public.user_achievements (
    user_id,
    achievement_id,
    unlocked_at,
    unlock_source,
    celebration_shown
  )
  VALUES (
    p_user_id,
    p_achievement_id,
    now(),
    p_unlock_source,
    p_unlock_source = 'backfill'
  )
  ON CONFLICT (user_id, achievement_id) DO NOTHING;
END;
$$;

CREATE OR REPLACE FUNCTION public.evaluate_achievements(
  p_user_id uuid,
  p_context text,
  p_unlock_source text DEFAULT 'live'
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  r record;
  v_threshold numeric;
  v_hour integer;
  v_met boolean;
BEGIN
  IF p_user_id IS NULL THEN
    RETURN;
  END IF;

  FOR r IN
    SELECT a.id, a.rule_type, a.rule_params
    FROM public.achievements a
    WHERE a.is_active = true
      AND (
        p_context = 'all'
        OR (p_context = 'trip' AND a.rule_type = 'trip_count')
        OR (p_context = 'settlement' AND a.rule_type IN ('settlement_count', 'lifetime_spend'))
        OR (p_context = 'expense' AND a.rule_type IN ('group_expense_count', 'lifetime_spend', 'early_expense'))
        OR (p_context = 'personal' AND a.rule_type IN ('personal_expense_count', 'lifetime_spend'))
        OR (p_context = 'group' AND a.rule_type = 'group_count')
        OR (p_context = 'friend' AND a.rule_type = 'friend_count')
        OR (p_context = 'goal' AND a.rule_type = 'goal_count')
        OR (p_context = 'loan' AND a.rule_type = 'loan_count')
      )
  LOOP
    v_met := false;
    v_threshold := COALESCE((r.rule_params ->> 'threshold')::numeric, 1);

    CASE r.rule_type
      WHEN 'trip_count' THEN
        v_met := public.achievement_trip_count(p_user_id) >= v_threshold;
      WHEN 'settlement_count' THEN
        v_met := public.achievement_settlement_count(p_user_id) >= v_threshold;
      WHEN 'lifetime_spend' THEN
        v_met := public.achievement_lifetime_spend_inr(p_user_id) >= v_threshold;
      WHEN 'early_expense' THEN
        v_hour := COALESCE((r.rule_params ->> 'hour')::integer, 8);
        v_met := public.achievement_has_early_expense(p_user_id, v_hour);
      WHEN 'group_expense_count' THEN
        v_met := public.achievement_group_expense_count(p_user_id) >= v_threshold;
      WHEN 'personal_expense_count' THEN
        v_met := public.achievement_personal_expense_count(p_user_id) >= v_threshold;
      WHEN 'group_count' THEN
        v_met := public.achievement_group_count(p_user_id) >= v_threshold;
      WHEN 'friend_count' THEN
        v_met := public.achievement_friend_count(p_user_id) >= v_threshold;
      WHEN 'goal_count' THEN
        v_met := public.achievement_goal_count(p_user_id) >= v_threshold;
      WHEN 'loan_count' THEN
        v_met := public.achievement_loan_count(p_user_id) >= v_threshold;
      ELSE
        v_met := false;
    END CASE;

    IF v_met THEN
      PERFORM public.grant_achievement(p_user_id, r.id, p_unlock_source);
    END IF;
  END LOOP;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_trip_metadata_achievements()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public.evaluate_achievements(NEW.created_by, 'trip');
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_group_transaction_achievements()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.sharing_type = 'settlement' OR NEW.category = 'Settlement' THEN
    PERFORM public.evaluate_achievements(NEW.paid_by, 'settlement');
    IF NEW.shared_with IS DISTINCT FROM NEW.paid_by THEN
      PERFORM public.evaluate_achievements(NEW.shared_with, 'settlement');
    END IF;
  ELSE
    PERFORM public.evaluate_achievements(NEW.paid_by, 'expense');
    IF NEW.shared_with IS DISTINCT FROM NEW.paid_by THEN
      PERFORM public.evaluate_achievements(NEW.shared_with, 'expense');
    END IF;
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_personal_transaction_achievements()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public.evaluate_achievements(NEW.user_id, 'personal');
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_groups_achievements()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.created_by IS NOT NULL THEN
    PERFORM public.evaluate_achievements(NEW.created_by, 'group');
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_friends_achievements()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.status = 'accepted' AND (OLD.status IS DISTINCT FROM 'accepted') THEN
    PERFORM public.evaluate_achievements(NEW.user_id, 'friend');
    PERFORM public.evaluate_achievements(NEW.friend_id, 'friend');
  END IF;
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_financial_goals_achievements()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  PERFORM public.evaluate_achievements(NEW.user_id, 'goal');
  RETURN NEW;
END;
$$;

CREATE OR REPLACE FUNCTION public.trg_loans_achievements()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF NEW.created_by IS NOT NULL THEN
    PERFORM public.evaluate_achievements(NEW.created_by, 'loan');
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS achievement_trip_metadata ON public.trip_metadata;
CREATE TRIGGER achievement_trip_metadata
  AFTER INSERT ON public.trip_metadata
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_trip_metadata_achievements();

DROP TRIGGER IF EXISTS achievement_group_transaction ON public.group_transaction;
CREATE TRIGGER achievement_group_transaction
  AFTER INSERT ON public.group_transaction
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_group_transaction_achievements();

DROP TRIGGER IF EXISTS achievement_personal_transaction ON public.personal_transaction;
CREATE TRIGGER achievement_personal_transaction
  AFTER INSERT ON public.personal_transaction
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_personal_transaction_achievements();

DROP TRIGGER IF EXISTS achievement_groups ON public.groups;
CREATE TRIGGER achievement_groups
  AFTER INSERT ON public.groups
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_groups_achievements();

DROP TRIGGER IF EXISTS achievement_friends ON public.friends;
CREATE TRIGGER achievement_friends
  AFTER UPDATE ON public.friends
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_friends_achievements();

DROP TRIGGER IF EXISTS achievement_financial_goals ON public.financial_goals;
CREATE TRIGGER achievement_financial_goals
  AFTER INSERT ON public.financial_goals
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_financial_goals_achievements();

DROP TRIGGER IF EXISTS achievement_loans ON public.loans;
CREATE TRIGGER achievement_loans
  AFTER INSERT ON public.loans
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_loans_achievements();

-- Silent backfill for existing users.
DO $$
DECLARE
  u record;
BEGIN
  FOR u IN SELECT user_id FROM public.users LOOP
    PERFORM public.evaluate_achievements(u.user_id, 'all', 'backfill');
  END LOOP;
END;
$$;
