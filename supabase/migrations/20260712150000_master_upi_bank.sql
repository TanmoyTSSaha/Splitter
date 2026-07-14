-- Master UPI bank / PSP names for profile VPA picker.

CREATE TABLE IF NOT EXISTS public.master_upi_bank (
  bank_slug text PRIMARY KEY,
  bank_name text NOT NULL UNIQUE,
  sort_order int NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT true
);

CREATE INDEX IF NOT EXISTS idx_master_upi_bank_sort
  ON public.master_upi_bank (sort_order, bank_name);

ALTER TABLE public.master_upi_bank ENABLE ROW LEVEL SECURITY;

CREATE POLICY master_upi_bank_read ON public.master_upi_bank
  FOR SELECT TO authenticated
  USING (is_active = true);

INSERT INTO public.master_upi_bank (bank_slug, bank_name, sort_order) VALUES
  ('au_small_finance_bank', 'AU Small Finance Bank', 1),
  ('airtel_payments_bank', 'Airtel Payments Bank', 2),
  ('amazon_pay', 'Amazon Pay', 3),
  ('axis_bank', 'Axis Bank', 4),
  ('bandhan_bank', 'Bandhan Bank', 5),
  ('bank_of_baroda', 'Bank of Baroda', 6),
  ('bank_of_india', 'Bank of India', 7),
  ('bank_of_maharashtra', 'Bank of Maharashtra', 8),
  ('bhim', 'BHIM', 9),
  ('canara_bank', 'Canara Bank', 10),
  ('central_bank_of_india', 'Central Bank of India', 11),
  ('city_union_bank', 'City Union Bank', 12),
  ('csb_bank', 'CSB Bank', 13),
  ('dbs_bank_india', 'DBS Bank India', 14),
  ('dcb_bank', 'DCB Bank', 15),
  ('deutsche_bank', 'Deutsche Bank', 16),
  ('dhanlaxmi_bank', 'Dhanlaxmi Bank', 17),
  ('equitas_small_finance_bank', 'Equitas Small Finance Bank', 18),
  ('federal_bank', 'Federal Bank', 19),
  ('fino_payments_bank', 'Fino Payments Bank', 20),
  ('google_pay', 'Google Pay', 21),
  ('hdfc_bank', 'HDFC Bank', 22),
  ('hsbc', 'HSBC', 23),
  ('icici_bank', 'ICICI Bank', 24),
  ('idbi_bank', 'IDBI Bank', 25),
  ('idfc_first_bank', 'IDFC FIRST Bank', 26),
  ('indian_bank', 'Indian Bank', 27),
  ('indian_overseas_bank', 'Indian Overseas Bank', 28),
  ('indusind_bank', 'IndusInd Bank', 29),
  ('jammu_kashmir_bank', 'Jammu & Kashmir Bank', 30),
  ('jio_payments_bank', 'Jio Payments Bank', 31),
  ('karnataka_bank', 'Karnataka Bank', 32),
  ('karur_vysya_bank', 'Karur Vysya Bank', 33),
  ('kotak_mahindra_bank', 'Kotak Mahindra Bank', 34),
  ('navi', 'Navi', 35),
  ('paytm_payments_bank', 'Paytm Payments Bank', 36),
  ('phonepe', 'PhonePe', 37),
  ('punjab_sind_bank', 'Punjab & Sind Bank', 38),
  ('punjab_national_bank', 'Punjab National Bank', 39),
  ('rbl_bank', 'RBL Bank', 40),
  ('sbi', 'SBI', 41),
  ('south_indian_bank', 'South Indian Bank', 42),
  ('standard_chartered', 'Standard Chartered', 43),
  ('state_bank_of_india', 'State Bank of India', 44),
  ('tamilnad_mercantile_bank', 'Tamilnad Mercantile Bank', 45),
  ('uco_bank', 'UCO Bank', 46),
  ('union_bank_of_india', 'Union Bank of India', 47),
  ('utkarsh_small_finance_bank', 'Utkarsh Small Finance Bank', 48),
  ('yes_bank', 'Yes Bank', 49)
ON CONFLICT (bank_slug) DO NOTHING;
