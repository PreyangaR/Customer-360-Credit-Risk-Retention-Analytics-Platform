{{ config(
    materialized='table'
) }}

SELECT
    t.transaction_id,

    origin.account_id AS origin_account_key,

    destination.account_id AS destination_account_key,

    tt.transaction_type_key,

    d.date_key,

    b.branch_key,

    t.amount,

    t.description

FROM {{ ref('int_customer_transactions') }} t

LEFT JOIN {{ ref('dim_account') }} origin
    ON t.origin_account_id = origin.account_id

LEFT JOIN {{ ref('dim_account') }} destination
    ON t.destination_account_id = destination.account_id

LEFT JOIN {{ ref('dim_transaction_type') }} tt
    ON t.transaction_type_id = tt.transaction_type_id

LEFT JOIN {{ ref('dim_date') }} d
    ON TO_DATE(t.transaction_date) = d.full_date

LEFT JOIN {{ ref('dim_branch') }} b
    ON t.branch_id = b.branch_id