{{ config(
    materialized='table'
) }}

SELECT
    loan_status_id AS loan_status_key,
    loan_status_id,
    status_name
FROM {{ ref('stg_loan_statuses') }}