-- Feature request lifecycle flag (dashboard-managed; no client UPDATE RLS).

ALTER TABLE public.feature_requests
  ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'open'
  CHECK (status IN ('open', 'implemented', 'closed'));

CREATE INDEX IF NOT EXISTS idx_feature_requests_status
  ON public.feature_requests (status);
