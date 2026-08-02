-- Per-payment history for loans (monthly recap F8 ledger rows).
CREATE TABLE IF NOT EXISTS public.loan_payments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  loan_id uuid NOT NULL REFERENCES public.loans (id) ON DELETE CASCADE,
  amount numeric NOT NULL CHECK (amount > 0),
  paid_by uuid NOT NULL REFERENCES auth.users (id) ON DELETE CASCADE,
  payment_date timestamptz NOT NULL DEFAULT now(),
  created_at timestamptz NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_loan_payments_loan_date
  ON public.loan_payments (loan_id, payment_date DESC);

CREATE INDEX IF NOT EXISTS idx_loan_payments_date
  ON public.loan_payments (payment_date);

ALTER TABLE public.loan_payments ENABLE ROW LEVEL SECURITY;

CREATE POLICY loan_payments_participant ON public.loan_payments
  FOR ALL TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.loans l
      WHERE l.id = loan_id
        AND (l.lender_id = auth.uid() OR l.borrower_id = auth.uid())
    )
  )
  WITH CHECK (
    paid_by = auth.uid()
    AND EXISTS (
      SELECT 1 FROM public.loans l
      WHERE l.id = loan_id
        AND (l.lender_id = auth.uid() OR l.borrower_id = auth.uid())
    )
  );
