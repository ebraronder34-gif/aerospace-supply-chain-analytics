-- ============================================================
-- 04. QUALITY VALIDATION
-- Purpose: Validate quality incidents, scrap quantity,
-- and critical incident rate against Power BI results
-- ============================================================
-- 1. Overall Quality Performance Validation

SELECT
    COUNT(DISTINCT incident_id) AS quality_incident_count,

    SUM(scrap_qty) AS total_scrapped_qty,

    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN defect_severity = 'Critical'
            THEN incident_id
        END)
        / COUNT(DISTINCT incident_id),
        1
    ) AS critical_incident_pct

FROM quality_incidents;
-- 2. Quality Performance by Defect Type

SELECT
    defect_type,
    COUNT(DISTINCT incident_id) AS quality_incident_count,
    SUM(scrap_qty) AS total_scrapped_qty,

    ROUND(
        100.0 * COUNT(DISTINCT CASE
            WHEN defect_severity = 'Critical'
            THEN incident_id
        END)
        / COUNT(DISTINCT incident_id),
        1
    ) AS critical_incident_pct

FROM quality_incidents

GROUP BY defect_type
ORDER BY quality_incident_count DESC;
