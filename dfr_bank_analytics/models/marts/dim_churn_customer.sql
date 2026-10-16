
{{ config(materialized='table') }}

SELECT
    customer_id,
    age,
    gender,
    dependents,
    occupation,
    city,
    customer_nw_category,
    vintage,
    branch_code
FROM {{ ref('int_churn_customer') }}
