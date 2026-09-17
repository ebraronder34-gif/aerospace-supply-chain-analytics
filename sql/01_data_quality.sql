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
