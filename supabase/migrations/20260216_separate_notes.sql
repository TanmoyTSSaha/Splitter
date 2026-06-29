-- 1. Add the new column
ALTER TABLE group_transaction ADD COLUMN IF NOT EXISTS transaction_note TEXT;

-- 2. Migrate existing data
-- Extract text after "Notes:" (case insensitive) into transaction_note
UPDATE group_transaction
SET
  transaction_note = TRIM(SUBSTRING(description FROM '(?i)Notes:(.*)')),
  description = TRIM(REGEXP_REPLACE(description, '(?i)Notes:.*', ''))
WHERE
  description ~* 'Notes:';
