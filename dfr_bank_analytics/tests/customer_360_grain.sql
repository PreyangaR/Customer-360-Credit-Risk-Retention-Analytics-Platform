SELECT
    customer_id
FROM {{ ref('mart_customer_360') }}
GROUP BY customer_id
HAVING COUNT(*) > 1