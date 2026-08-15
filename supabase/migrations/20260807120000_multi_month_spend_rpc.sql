-- Batch monthly spend totals for insights trend charts (PERF-02 / D-08).
CREATE OR REPLACE FUNCTION public.get_multi_month_spend_totals(
  p_user_id uuid,
  p_months integer DEFAULT 6,
  p_end_month date DEFAULT NULL
)
RETURNS TABLE(month_start date, total_inr numeric)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_end date := COALESCE(
    p_end_month,
    date_trunc('month', now() AT TIME ZONE 'UTC')::date
  );
BEGIN
  IF auth.uid() IS NULL OR auth.uid() <> p_user_id THEN
    RAISE EXCEPTION 'unauthorized';
  END IF;

  IF p_months < 1 OR p_months > 24 THEN
    RAISE EXCEPTION 'p_months must be between 1 and 24';
  END IF;

  RETURN QUERY
  WITH month_series AS (
    SELECT (date_trunc('month', v_end::timestamp) - (n || ' months')::interval)::date AS month_start
    FROM generate_series(0, p_months - 1) AS n
  ),
  personal AS (
    SELECT
      date_trunc('month', transaction_date)::date AS month_start,
      SUM(
        amount::numeric * COALESCE(NULLIF(exchange_rate_to_inr::text, '')::numeric, 1)
      ) AS total
    FROM personal_transaction
    WHERE user_id = p_user_id
      AND is_credit = false
      AND LOWER(COALESCE(category, '')) NOT IN (
        'settlement', 'income', 'salary', 'refund', 'cashback', 'reimbursement'
      )
    GROUP BY 1
  ),
  group_spend AS (
    SELECT
      date_trunc('month', transaction_date)::date AS month_start,
      SUM(
        shared_transaction_amount::numeric
          * COALESCE(NULLIF(exchange_rate_to_inr::text, '')::numeric, 1)
      ) AS total
    FROM group_transaction
    WHERE shared_with = p_user_id
      AND LOWER(COALESCE(category, '')) NOT IN (
        'settlement', 'income', 'salary', 'refund', 'cashback', 'reimbursement'
      )
    GROUP BY 1
  )
  SELECT
    m.month_start,
    COALESCE(p.total, 0) + COALESCE(g.total, 0)
  FROM month_series m
  LEFT JOIN personal p ON p.month_start = m.month_start
  LEFT JOIN group_spend g ON g.month_start = m.month_start
  ORDER BY m.month_start ASC;
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_multi_month_spend_totals(uuid, integer, date)
  TO authenticated;
