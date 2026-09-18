-- ============================================================
-- 01. DATA QUALITY VALIDATION
-- Aerospace Supply Chain Analytics
-- Purpose: Validate dataset grain, duplicates, and key fields
-- ============================================================

-- 1. Validate Purchase Order grain
-- Expected: Each PO ID should represent one unique purchase order.

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT po_id) AS distinct_po_ids,
    COUNT(*) - COUNT(DISTINCT po_id) AS duplicate_po_ids
FROM purchase_orders;
-- 2. Check missing values in critical Purchase Order fields

SELECT
    SUM(CASE WHEN order_date IS NULL THEN 1 ELSE 0 END) AS missing_order_date,
    SUM(CASE WHEN promised_date IS NULL THEN 1 ELSE 0 END) AS missing_promised_date,
    SUM(CASE WHEN receipt_date IS NULL THEN 1 ELSE 0 END) AS missing_receipt_date,
    SUM(CASE WHEN ordered_qty IS NULL THEN 1 ELSE 0 END) AS missing_ordered_qty,
    SUM(CASE WHEN received_qty IS NULL THEN 1 ELSE 0 END) AS missing_received_qty
FROM purchase_orders;

-- 3. Invalid Quantity & Date Logic Check

WITH parsed_dates AS (
    SELECT
        ordered_qty,
        received_qty,

        printf(
            '%04d-%02d-%02d',
            CAST(substr(order_date, -4) AS INTEGER),
            CAST(substr(order_date, 1, instr(order_date, '/') - 1) AS INTEGER),
            CAST(substr(
                order_date,
                instr(order_date, '/') + 1,
                instr(substr(order_date, instr(order_date, '/') + 1), '/') - 1
            ) AS INTEGER)
        ) AS order_date_parsed,

        printf(
            '%04d-%02d-%02d',
            CAST(substr(promised_date, -4) AS INTEGER),
            CAST(substr(promised_date, 1, instr(promised_date, '/') - 1) AS INTEGER),
            CAST(substr(
                promised_date,
                instr(promised_date, '/') + 1,
                instr(substr(promised_date, instr(promised_date, '/') + 1), '/') - 1
            ) AS INTEGER)
        ) AS promised_date_parsed,

        printf(
            '%04d-%02d-%02d',
            CAST(substr(receipt_date, -4) AS INTEGER),
            CAST(substr(receipt_date, 1, instr(receipt_date, '/') - 1) AS INTEGER),
            CAST(substr(
                receipt_date,
                instr(receipt_date, '/') + 1,
                instr(substr(receipt_date, instr(receipt_date, '/') + 1), '/') - 1
            ) AS INTEGER)
        ) AS receipt_date_parsed

    FROM purchase_orders
)

SELECT
    SUM(CASE WHEN ordered_qty <= 0 THEN 1 ELSE 0 END)
        AS invalid_ordered_qty,

    SUM(CASE WHEN received_qty < 0 THEN 1 ELSE 0 END)
        AS invalid_received_qty,

    SUM(CASE WHEN promised_date_parsed < order_date_parsed THEN 1 ELSE 0 END)
        AS promised_before_order,

    SUM(CASE WHEN receipt_date_parsed < order_date_parsed THEN 1 ELSE 0 END)
        AS receipt_before_order

FROM parsed_dates;

-- Finding:
-- Quantity checks returned no invalid values.
-- However, 6,564 POs have promised dates before order dates,
-- and 6,680 POs have receipt dates before order dates.
-- These records were flagged as potential date-quality issues
-- requiring business/source-system validation.
