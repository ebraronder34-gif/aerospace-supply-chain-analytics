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

SELECT
    SUM(CASE WHEN ordered_qty <= 0 THEN 1 ELSE 0 END) AS invalid_ordered_qty,
    SUM(CASE WHEN received_qty < 0 THEN 1 ELSE 0 END) AS invalid_received_qty,
    SUM(CASE WHEN promised_date < order_date THEN 1 ELSE 0 END) AS promised_before_order,
    SUM(CASE WHEN receipt_date < order_date THEN 1 ELSE 0 END) AS receipt_before_order
FROM purchase_orders;
-- Finding:
-- Quantity checks returned no invalid values.
-- However, 6,564 POs have promised dates before order dates,
-- and 6,680 POs have receipt dates before order dates.
-- These records were flagged as potential date-quality issues
-- requiring business/source-system validation.
