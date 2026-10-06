SELECT
    customer_id
FROM {{ ref('mart_retention') }}
GROUP BY customer_id
HAVING COUNT(*) > 1