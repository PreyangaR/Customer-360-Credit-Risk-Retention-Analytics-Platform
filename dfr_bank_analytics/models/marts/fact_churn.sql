
{{ config(materialized='table') }}

SELECT
    c.customer_id,
    c.churn,

    c.current_balance,
    c.previous_month_end_balance,
    c.average_monthly_balance_prevQ,
    c.average_monthly_balance_prevQ2,

    c.current_month_credit,
    c.previous_month_credit,
    c.current_month_debit,
    c.previous_month_debit,

    c.current_month_balance,
    c.previous_month_balance,

    d.date_key AS last_transaction_date_key,
    c.last_transaction

FROM {{ ref('int_churn_customer') }} c

LEFT JOIN {{ ref('dim_date') }} d
    ON TO_DATE(c.last_transaction) = d.full_date
