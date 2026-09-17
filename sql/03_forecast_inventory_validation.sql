-- ============================================================
-- 03. FORECAST & INVENTORY VALIDATION
-- Purpose: Validate forecast accuracy and inventory exposure
-- against Power BI results
-- ============================================================
SELECT
    SUM(consumption_qty) AS total_consumption,
    SUM(forecast_qty) AS total_forecast,

    SUM(
        ABS(consumption_qty - forecast_qty)
    ) AS absolute_error,

    ROUND(
        100.0 * SUM(ABS(consumption_qty - forecast_qty))
        / SUM(consumption_qty),
        1
    ) AS wape_pct,

    ROUND(
        100.0 * (SUM(forecast_qty) - SUM(consumption_qty))
        / SUM(consumption_qty),
        1
    ) AS forecast_bias_pct

FROM supply_chain_history;
-- 2. Forecast Performance by Site

SELECT
    site_id,

    SUM(consumption_qty) AS total_consumption,
    SUM(forecast_qty) AS total_forecast,

    SUM(
        ABS(consumption_qty - forecast_qty)
    ) AS absolute_error,

    ROUND(
        100.0 * SUM(ABS(consumption_qty - forecast_qty))
        / SUM(consumption_qty),
        1
    ) AS wape_pct,

    ROUND(
        100.0 * (SUM(forecast_qty) - SUM(consumption_qty))
        / SUM(consumption_qty),
        1
    ) AS forecast_bias_pct

FROM supply_chain_history

GROUP BY site_id
ORDER BY wape_pct DESC;

-- 3. Forecast Performance by Part Family

SELECT
    p.part_family,

    SUM(s.consumption_qty) AS total_consumption,
    SUM(s.forecast_qty) AS total_forecast,

    SUM(
        ABS(s.consumption_qty - s.forecast_qty)
    ) AS absolute_error,

    ROUND(
        100.0 * SUM(ABS(s.consumption_qty - s.forecast_qty))
        / SUM(s.consumption_qty),
        1
    ) AS wape_pct,

    ROUND(
        100.0 * (SUM(s.forecast_qty) - SUM(s.consumption_qty))
        / SUM(s.consumption_qty),
        1
    ) AS forecast_bias_pct

FROM supply_chain_history s

JOIN parts_master p
    ON s.part_id = p.part_id

GROUP BY p.part_family
ORDER BY wape_pct DESC;

-- 4. Latest Inventory Snapshot Validation
-- Dates are stored as M/D/YYYY text, so they are parsed
-- before identifying the latest snapshot.

WITH parsed_history AS (
    SELECT
        *,
        printf(
            '%04d-%02d-%02d',
            CAST(substr(Date, -4) AS INTEGER),
            CAST(substr(Date, 1, instr(Date, '/') - 1) AS INTEGER),
            CAST(substr(
                Date,
                instr(Date, '/') + 1,
                instr(substr(Date, instr(Date, '/') + 1), '/') - 1
            ) AS INTEGER)
        ) AS parsed_date
    FROM supply_chain_history
),

latest_snapshot AS (
    SELECT MAX(parsed_date) AS latest_date
    FROM parsed_history
)

SELECT
    l.latest_date,
    SUM(p.on_hand_qty) AS latest_on_hand_qty,
    SUM(p.blocked_qty) AS latest_blocked_qty,
    SUM(p.on_hand_qty) - SUM(p.blocked_qty) AS latest_available_qty,
    SUM(p.backorder_qty) AS latest_backorder_qty,

    ROUND(
        100.0 * SUM(p.blocked_qty) / SUM(p.on_hand_qty),
        1
    ) AS blocked_stock_pct

FROM parsed_history p
CROSS JOIN latest_snapshot l
WHERE p.parsed_date = l.latest_date
GROUP BY l.latest_date;
