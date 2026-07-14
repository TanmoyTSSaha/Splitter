-- Budget periods, limit rename, per-budget group toggle, partial unique indexes.

ALTER TABLE public.personal_budgets
  ADD COLUMN IF NOT EXISTS period text NOT NULL DEFAULT 'monthly',
  ADD COLUMN IF NOT EXISTS include_group_expenses boolean NOT NULL DEFAULT true;

ALTER TABLE public.personal_budgets
  RENAME COLUMN monthly_limit TO limit_amount;

ALTER TABLE public.personal_budgets
  DROP CONSTRAINT IF EXISTS personal_budgets_user_id_category_key;

CREATE UNIQUE INDEX IF NOT EXISTS personal_budgets_user_category_period
  ON public.personal_budgets (user_id, category, period)
  WHERE category IS NOT NULL;

CREATE UNIQUE INDEX IF NOT EXISTS personal_budgets_user_overall_period
  ON public.personal_budgets (user_id, period)
  WHERE category IS NULL;
