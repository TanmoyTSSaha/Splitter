-- Add created_by for lend-offer vs borrow-request acceptance routing,
-- and monthly repayment window day fields.

ALTER TABLE public.loans
  ADD COLUMN IF NOT EXISTS created_by uuid REFERENCES auth.users (id),
  ADD COLUMN IF NOT EXISTS repayment_start_day integer,
  ADD COLUMN IF NOT EXISTS repayment_end_day integer;

-- Historical rows were lender-initiated offers.
UPDATE public.loans
SET created_by = lender_id
WHERE created_by IS NULL;
