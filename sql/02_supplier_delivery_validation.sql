-- 1. Overall On-Time Delivery (OTD) Validation

SELECT
    COUNT(DISTINCT po_id) AS total_po,
    
    COUNT(DISTINCT CASE
        WHEN receipt_date <= promised_date THEN po_id
    END) AS on_time_po,
    
    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN receipt_date <= promised_date THEN po_id
        END)
        / COUNT(DISTINCT po_id),
        1
    ) AS otd_pct

FROM purchase_orders;
-- 2. Overall In Full Performance Validation

SELECT
    COUNT(DISTINCT po_id) AS total_po,

    COUNT(DISTINCT CASE
        WHEN received_qty >= ordered_qty THEN po_id
    END) AS in_full_po,

    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN received_qty >= ordered_qty THEN po_id
        END)
        / COUNT(DISTINCT po_id),
        1
    ) AS in_full_pct

FROM purchase_orders;
