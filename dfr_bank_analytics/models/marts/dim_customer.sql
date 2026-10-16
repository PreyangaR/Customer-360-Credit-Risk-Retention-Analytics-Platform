{{ config(
    materialized='table'
) }}

SELECT
    customer_id,
    first_name,
    last_name,
    date_of_birth,
    customer_type,
    street,
    city,
    country
FROM {{ ref('int_customer_core') }}