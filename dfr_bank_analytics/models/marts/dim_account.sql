{{ config(
    materialized='table'
) }}

SELECT
    account_id,
    customer_id,
    account_type,
    account_status,
    balance,
    opening_date
FROM {{ ref('int_customer_accounts') }}