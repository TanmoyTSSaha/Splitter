-- Keep feature_requests.vote_count in sync with feature_request_votes junction rows.
-- Client must not UPDATE vote_count directly (no UPDATE RLS on feature_requests).

ALTER TABLE public.feature_requests
  ALTER COLUMN vote_count SET DEFAULT 0;

CREATE OR REPLACE FUNCTION public.sync_feature_request_vote_count()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE public.feature_requests
    SET vote_count = vote_count + 1
    WHERE id = NEW.request_id;
    RETURN NEW;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE public.feature_requests
    SET vote_count = GREATEST(vote_count - 1, 0)
    WHERE id = OLD.request_id;
    RETURN OLD;
  END IF;
  RETURN NULL;
END;
$$;

DROP TRIGGER IF EXISTS trg_feature_request_vote_count ON public.feature_request_votes;

CREATE TRIGGER trg_feature_request_vote_count
AFTER INSERT OR DELETE ON public.feature_request_votes
FOR EACH ROW
EXECUTE FUNCTION public.sync_feature_request_vote_count();

-- Backfill counts from existing votes.
UPDATE public.feature_requests fr
SET vote_count = COALESCE((
  SELECT COUNT(*)::integer
  FROM public.feature_request_votes v
  WHERE v.request_id = fr.id
), 0);
