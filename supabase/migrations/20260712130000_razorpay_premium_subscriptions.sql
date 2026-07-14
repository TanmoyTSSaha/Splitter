-- Razorpay subscription billing for Splitr Pro (replaces client-side IAP premium writes).

-- ─── Subscription records ────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.premium_subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL UNIQUE REFERENCES public.users (user_id) ON DELETE CASCADE,
  razorpay_subscription_id text UNIQUE,
  razorpay_customer_id text,
  razorpay_plan_id text NOT NULL,
  plan_interval text NOT NULL CHECK (plan_interval IN ('monthly', 'yearly')),
  status text NOT NULL DEFAULT 'created' CHECK (
    status IN (
      'created',
      'authenticated',
      'active',
      'halted',
      'cancelled',
      'completed',
      'pending'
    )
  ),
  current_period_end timestamptz,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_premium_subscriptions_user_id
  ON public.premium_subscriptions (user_id);

CREATE INDEX IF NOT EXISTS idx_premium_subscriptions_razorpay_id
  ON public.premium_subscriptions (razorpay_subscription_id)
  WHERE razorpay_subscription_id IS NOT NULL;

-- ─── Webhook idempotency ─────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.webhook_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  provider text NOT NULL DEFAULT 'razorpay',
  event_id text NOT NULL,
  event_type text NOT NULL,
  payload jsonb NOT NULL,
  processed_at timestamptz NOT NULL DEFAULT now(),
  UNIQUE (provider, event_id)
);

CREATE INDEX IF NOT EXISTS idx_webhook_events_provider_type
  ON public.webhook_events (provider, event_type);

-- ─── Sync users.is_premium from subscription row ─────────────────────────────
CREATE OR REPLACE FUNCTION public.sync_user_premium_from_subscription()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  premium_active boolean;
  premium_expires timestamptz;
BEGIN
  premium_expires := NEW.current_period_end;

  premium_active := NEW.status IN ('active', 'authenticated', 'cancelled')
    AND (
      premium_expires IS NULL
      OR premium_expires > now()
    );

  IF NEW.status IN ('halted', 'completed', 'created', 'pending') THEN
    premium_active := false;
  END IF;

  UPDATE public.users
  SET
    is_premium = premium_active,
    premium_expires_at = CASE
      WHEN premium_active THEN premium_expires
      ELSE NULL
    END
  WHERE user_id = NEW.user_id;

  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_sync_user_premium_from_subscription
  ON public.premium_subscriptions;

CREATE TRIGGER trg_sync_user_premium_from_subscription
  AFTER INSERT OR UPDATE OF status, current_period_end
  ON public.premium_subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION public.sync_user_premium_from_subscription();

-- ─── Block client self-grant of premium flags ───────────────────────────────
CREATE OR REPLACE FUNCTION public.prevent_client_premium_self_grant()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF auth.role() = 'authenticated'
    AND (
      OLD.is_premium IS DISTINCT FROM NEW.is_premium
      OR OLD.premium_expires_at IS DISTINCT FROM NEW.premium_expires_at
    ) THEN
    RAISE EXCEPTION 'Premium status is managed by Razorpay subscriptions only';
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_prevent_client_premium_self_grant ON public.users;

CREATE TRIGGER trg_prevent_client_premium_self_grant
  BEFORE UPDATE ON public.users
  FOR EACH ROW
  EXECUTE FUNCTION public.prevent_client_premium_self_grant();

-- ─── RLS ─────────────────────────────────────────────────────────────────────
ALTER TABLE public.premium_subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.webhook_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS premium_subscriptions_select_own
  ON public.premium_subscriptions;

CREATE POLICY premium_subscriptions_select_own
  ON public.premium_subscriptions
  FOR SELECT
  TO authenticated
  USING (auth.uid() = user_id);

-- webhook_events: service role only (no authenticated policies)
