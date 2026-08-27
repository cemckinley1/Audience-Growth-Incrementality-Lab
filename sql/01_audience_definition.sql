-- Audience: customers with prior purchases who have not purchased in 90-365 days.
-- Suppress unsubscribed customers and anyone contacted in the last 7 days.
WITH customer_features AS (
    SELECT
        c.customer_id,
        MAX(o.order_date) AS last_order_date,
        SUM(o.order_revenue) AS lifetime_revenue,
        COUNT(DISTINCT o.order_id) AS lifetime_orders
    FROM customers AS c
    JOIN orders AS o 
    ON c.customer_id = o.customer_id
    GROUP BY c.customer_id
)
SELECT
    f.customer_id,
    'Lapsing Customers' AS audience_segment,
    CASE
        WHEN c.email_opt_in = FALSE THEN 'Suppressed: Opt Out'
        WHEN c.last_contact_date >= CURRENT_DATE - INTERVAL '7 days' THEN 'Suppressed: Contact Policy'
        ELSE 'Eligible'
    END AS audience_status
FROM customer_features AS f
JOIN customers AS c 
ON f.customer_id = c.customer_id
WHERE f.last_order_date BETWEEN CURRENT_DATE - INTERVAL '365 days'
                            AND CURRENT_DATE - INTERVAL '90 days';
