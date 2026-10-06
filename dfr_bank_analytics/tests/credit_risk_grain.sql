SELECT
    customer_id
FROM {{ ref('mart_credit_risk') }}
GROUP BY customer_id
HAVING COUNT(*) > 1