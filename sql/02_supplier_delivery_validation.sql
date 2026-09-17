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
-- 3. Overall OTIF Performance Validation

WITH parsed_dates AS (
    SELECT
        po_id,
        ordered_qty,
        received_qty,

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
    COUNT(DISTINCT po_id) AS total_po,

    COUNT(DISTINCT CASE
        WHEN receipt_date_parsed <= promised_date_parsed
         AND received_qty >= ordered_qty
        THEN po_id
    END) AS otif_po,

    ROUND(
        100.0 *
        COUNT(DISTINCT CASE
            WHEN receipt_date_parsed <= promised_date_parsed
             AND received_qty >= ordered_qty
            THEN po_id
        END)
        / COUNT(DISTINCT po_id),
        1
    ) AS otif_pct

FROM parsed_dates;
WITH parsed_dates AS (
    SELECT
        po_id,
        supplier_id,
        ordered_qty,
        received_qty,

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

    FROM purchaseorders
)

SELECT
    supplier_id,
    COUNT(DISTINCT po_id) AS total_po,

    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN receipt_date_parsed <= promised_date_parsed THEN po_id
        END) / COUNT(DISTINCT po_id),
        1
    ) AS otd_pct,

    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN received_qty >= ordered_qty THEN po_id
        END) / COUNT(DISTINCT po_id),
        1
    ) AS in_full_pct,

    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN receipt_date_parsed <= promised_date_parsed
             AND received_qty >= ordered_qty
            THEN po_id
        END) / COUNT(DISTINCT po_id),
        1
    ) AS otif_pct

FROM parsed_dates
GROUP BY supplier_id
ORDER BY otif_pct ASC;
