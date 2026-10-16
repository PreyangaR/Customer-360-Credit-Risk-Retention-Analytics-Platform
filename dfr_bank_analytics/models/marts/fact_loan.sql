{{ config(
    materialized='table'
) }}

SELECT
    l.loan_id,

    a.account_id AS account_key,

    ls.loan_status_key,

    start_date.date_key AS start_date_key,

    end_date.date_key AS end_date_key,

    l.principal_amount,

    l.interest_rate

FROM {{ ref('int_customer_loans') }} l

LEFT JOIN {{ ref('dim_account') }} a
    ON l.account_id = a.account_id

LEFT JOIN {{ ref('dim_loan_status') }} ls
    ON l.loan_status_id = ls.loan_status_id

LEFT JOIN {{ ref('dim_date') }} start_date
    ON TO_DATE(l.start_date) = start_date.full_date

LEFT JOIN {{ ref('dim_date') }} end_date
    ON TO_DATE(l.estimated_end_date) = end_date.full_date