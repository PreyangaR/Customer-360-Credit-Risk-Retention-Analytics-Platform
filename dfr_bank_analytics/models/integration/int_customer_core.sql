SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.date_of_birth,
    c.customer_type_id,
    ct.type_name AS customer_type,
    c.address_id,
    a.street,
    a.city,
    a.country
FROM {{ ref('stg_customers') }} c
LEFT JOIN {{ ref('stg_customer_types') }} ct
    ON c.customer_type_id = ct.customer_type_id
LEFT JOIN {{ ref('stg_addresses') }} a
    ON c.address_id = a.address_id