{{ config(
    materialized='table'
) }}

SELECT
    transaction_type_id AS transaction_type_key,
    transaction_type_id,
    type_name
FROM {{ ref('stg_transaction_types') }}