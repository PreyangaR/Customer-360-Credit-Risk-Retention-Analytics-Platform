SELECT
    a.account_id,
    a.customer_id,
    c.customer_type,
    c.city,
    c.country,
    a.account_type_id,
    at.type_name AS account_type,
    a.account_status_id,
    ast.status_name AS account_status,
    a.balance,
    a.opening_date
FROM {{ ref('stg_accounts') }} a
LEFT JOIN {{ ref('int_customer_core') }} c
    ON a.customer_id = c.customer_id
LEFT JOIN {{ ref('stg_account_types') }} at
    ON a.account_type_id = at.account_type_id
LEFT JOIN {{ ref('stg_account_statuses') }} ast
    ON a.account_status_id = ast.account_status_id