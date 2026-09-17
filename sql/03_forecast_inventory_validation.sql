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
