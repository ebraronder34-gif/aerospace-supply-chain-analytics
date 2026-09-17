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
