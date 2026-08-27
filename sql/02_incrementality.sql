-- Compare treatment and control conversion, then estimate outcomes caused by campaign.
WITH group_results AS (
    SELECT
        audience_segment,
        experiment_group,
        COUNT(DISTINCT customer_id) AS customers,
        SUM(converted) AS conversions,
        SUM(revenue) AS revenue,
        1.0 * SUM(converted) / NULLIF(COUNT(DISTINCT customer_id), 0) AS conversion_rate
    FROM customer_campaign_results
    WHERE experiment_group IN ('Treatment', 'Control')
    GROUP BY audience_segment, experiment_group
), comparison AS (
    SELECT
        audience_segment,
        MAX(CASE WHEN experiment_group='Treatment' THEN customers END) AS treatment_customers,
        MAX(CASE WHEN experiment_group='Treatment' THEN conversion_rate END) AS treatment_rate,
        MAX(CASE WHEN experiment_group='Control' THEN conversion_rate END) AS control_rate
    FROM group_results
    GROUP BY audience_segment
)
SELECT
    audience_segment,
    treatment_rate,
    control_rate,
    treatment_rate - control_rate AS absolute_lift,
    treatment_rate / NULLIF(control_rate, 0) - 1 AS relative_lift,
    treatment_customers * (treatment_rate - control_rate) AS incremental_conversions
FROM comparison
ORDER BY incremental_conversions DESC;
