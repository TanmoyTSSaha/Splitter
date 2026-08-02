-- FCM push: device tokens, preferences, notification triggers, dispatch tracking.

-- ─── Dispatch tracking on inbox rows ─────────────────────────────────────────
ALTER TABLE public.notifications
  ADD COLUMN IF NOT EXISTS push_dispatched_at timestamptz;

CREATE INDEX IF NOT EXISTS idx_notifications_push_pending
  ON public.notifications (created_at)
  WHERE push_dispatched_at IS NULL;

-- ─── Device tokens ───────────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.device_tokens (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  token text NOT NULL,
  platform text NOT NULL DEFAULT 'android',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, token)
);

CREATE INDEX IF NOT EXISTS idx_device_tokens_user
  ON public.device_tokens (user_id);

-- ─── Granular push preferences ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.push_preferences (
  user_id uuid PRIMARY KEY REFERENCES auth.users (id) ON DELETE CASCADE,
  friend_request boolean NOT NULL DEFAULT true,
  group_invite boolean NOT NULL DEFAULT true,
  expense_added boolean NOT NULL DEFAULT true,
  settlement boolean NOT NULL DEFAULT true,
  settlement_reminder boolean NOT NULL DEFAULT true,
  loan_request boolean NOT NULL DEFAULT true,
  budget_alert boolean NOT NULL DEFAULT true,
  marketing boolean NOT NULL DEFAULT false,
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- ─── Server-side dedupe for scheduled pushes ─────────────────────────────────
CREATE TABLE IF NOT EXISTS public.budget_alert_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  budget_id uuid NOT NULL REFERENCES public.personal_budgets (id) ON DELETE CASCADE,
  period_key text NOT NULL,
  alert_type text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, budget_id, period_key, alert_type)
);

CREATE TABLE IF NOT EXISTS public.settlement_reminder_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  group_id uuid NOT NULL REFERENCES public.groups (group_id) ON DELETE CASCADE,
  counterparty_id uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  sent_on date NOT NULL DEFAULT CURRENT_DATE,
  created_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (user_id, group_id, counterparty_id, sent_on)
);

-- Optional pg_net dispatch config (set function_url + webhook_secret in prod).
CREATE TABLE IF NOT EXISTS public.push_webhook_config (
  id int PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  function_url text,
  webhook_secret text
);

INSERT INTO public.push_webhook_config (id)
VALUES (1)
ON CONFLICT (id) DO NOTHING;

-- ─── RLS ─────────────────────────────────────────────────────────────────────
ALTER TABLE public.device_tokens ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.push_preferences ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.budget_alert_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settlement_reminder_log ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.push_webhook_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY device_tokens_own ON public.device_tokens
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY push_preferences_own ON public.push_preferences
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY budget_alert_log_own ON public.budget_alert_log
  FOR ALL TO authenticated
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

-- Service role manages reminder logs + webhook config (no authenticated policies).

-- ─── Helpers ─────────────────────────────────────────────────────────────────
CREATE OR REPLACE FUNCTION public.display_user_name(p_user_id uuid)
RETURNS text
LANGUAGE sql
STABLE
SET search_path = public
AS $$
  SELECT COALESCE(
    NULLIF(trim(COALESCE(u.firstname, '') || ' ' || COALESCE(u.lastname, '')), ''),
    u.user_name,
    'Someone'
  )
  FROM public.users u
  WHERE u.user_id = p_user_id;
$$;

CREATE OR REPLACE FUNCTION public.ensure_push_preferences(p_user_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.push_preferences (user_id)
  VALUES (p_user_id)
  ON CONFLICT (user_id) DO NOTHING;
END;
$$;

GRANT EXECUTE ON FUNCTION public.ensure_push_preferences(uuid) TO authenticated;

-- ─── Inbox triggers: expense / invite / loan ─────────────────────────────────
CREATE OR REPLACE FUNCTION public.trg_notify_expense_added()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_group_name text;
  v_payer_name text;
  v_body text;
  v_member uuid;
BEGIN
  IF NEW.sharing_type = 'settlement' THEN
    RETURN NEW;
  END IF;

  IF (
    SELECT count(*)
    FROM public.group_transaction gt
    WHERE gt.transaction_group_id = NEW.transaction_group_id
  ) > 1 THEN
    RETURN NEW;
  END IF;

  SELECT g.group_name INTO v_group_name
  FROM public.groups g
  WHERE g.group_id = NEW.group_id;

  v_payer_name := public.display_user_name(NEW.paid_by);
  v_body := v_payer_name || ' added "' || COALESCE(NEW.description, 'an expense')
    || '" in ' || COALESCE(v_group_name, 'your group');

  FOR v_member IN
    SELECT gm.user_id
    FROM public.group_members gm
    WHERE gm.group_id = NEW.group_id
      AND gm.user_id <> NEW.paid_by
  LOOP
    INSERT INTO public.notifications (user_id, type, title, body, metadata, is_read)
    VALUES (
      v_member,
      'expense_added',
      'New expense',
      v_body,
      jsonb_build_object(
        'group_id', NEW.group_id,
        'transaction_group_id', NEW.transaction_group_id,
        'paid_by', NEW.paid_by
      ),
      false
    );
  END LOOP;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS notify_expense_added ON public.group_transaction;
CREATE TRIGGER notify_expense_added
  AFTER INSERT ON public.group_transaction
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_notify_expense_added();

CREATE OR REPLACE FUNCTION public.trg_notify_group_invite()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_group_name text;
  v_inviter_name text;
  v_body text;
BEGIN
  IF NEW.status <> 'pending' THEN
    RETURN NEW;
  END IF;

  SELECT g.group_name INTO v_group_name
  FROM public.groups g
  WHERE g.group_id = NEW.group_id;

  v_inviter_name := public.display_user_name(NEW.invited_by);
  v_body := v_inviter_name || ' invited you to join '
    || COALESCE(v_group_name, 'a group');

  INSERT INTO public.notifications (user_id, type, title, body, metadata, is_read)
  VALUES (
    NEW.invited_user_id,
    'group_invite',
    'Group invite',
    v_body,
    jsonb_build_object(
      'group_id', NEW.group_id,
      'invite_id', NEW.id,
      'invited_by', NEW.invited_by
    ),
    false
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS notify_group_invite ON public.group_invites;
CREATE TRIGGER notify_group_invite
  AFTER INSERT ON public.group_invites
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_notify_group_invite();

CREATE OR REPLACE FUNCTION public.trg_notify_loan_request()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_target uuid;
  v_actor_name text;
  v_body text;
BEGIN
  IF NEW.status <> 'pending' THEN
    RETURN NEW;
  END IF;

  IF NEW.created_by IS NULL THEN
    RETURN NEW;
  END IF;

  IF NEW.created_by = NEW.lender_id THEN
    v_target := NEW.borrower_id;
    v_body := public.display_user_name(NEW.lender_id)
      || ' sent you a loan offer';
  ELSIF NEW.created_by = NEW.borrower_id THEN
    v_target := NEW.lender_id;
    v_body := public.display_user_name(NEW.borrower_id)
      || ' requested a loan from you';
  ELSE
    RETURN NEW;
  END IF;

  IF v_target = NEW.created_by THEN
    RETURN NEW;
  END IF;

  v_actor_name := public.display_user_name(NEW.created_by);

  INSERT INTO public.notifications (user_id, type, title, body, metadata, is_read)
  VALUES (
    v_target,
    'loan_request',
    'Loan request',
    v_body,
    jsonb_build_object(
      'loan_id', NEW.id,
      'created_by', NEW.created_by,
      'lender_id', NEW.lender_id,
      'borrower_id', NEW.borrower_id
    ),
    false
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS notify_loan_request ON public.loans;
CREATE TRIGGER notify_loan_request
  AFTER INSERT ON public.loans
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_notify_loan_request();

-- ─── Optional instant push dispatch via pg_net ───────────────────────────────
CREATE OR REPLACE FUNCTION public.trg_dispatch_push_notification()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_url text;
  v_secret text;
BEGIN
  SELECT function_url, webhook_secret
  INTO v_url, v_secret
  FROM public.push_webhook_config
  WHERE id = 1;

  IF v_url IS NULL OR v_url = '' THEN
    RETURN NEW;
  END IF;

  PERFORM net.http_post(
    url := v_url,
    headers := jsonb_build_object(
      'Content-Type', 'application/json',
      'X-Push-Secret', COALESCE(v_secret, '')
    ),
    body := jsonb_build_object(
      'type', 'INSERT',
      'table', 'notifications',
      'record', jsonb_build_object(
        'id', NEW.id,
        'user_id', NEW.user_id,
        'type', NEW.type,
        'title', NEW.title,
        'body', NEW.body,
        'metadata', NEW.metadata,
        'is_read', NEW.is_read,
        'created_at', NEW.created_at
      )
    )
  );

  RETURN NEW;
EXCEPTION
  WHEN undefined_function THEN
    RETURN NEW;
  WHEN OTHERS THEN
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS dispatch_push_notification ON public.notifications;
CREATE TRIGGER dispatch_push_notification
  AFTER INSERT ON public.notifications
  FOR EACH ROW
  EXECUTE FUNCTION public.trg_dispatch_push_notification();
