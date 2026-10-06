SELECT
    t.transaction_id,

    t.account_origin_id AS origin_account_id,
    origin.customer_id AS origin_customer_id,

    t.account_destination_id AS destination_account_id,
    destination.customer_id AS destination_customer_id,

    t.transaction_type_id,
    tt.type_name AS transaction_type,

    t.amount,
    t.transaction_date,

    t.branch_id,
    b.branch_name,

    t.description

FROM {{ ref('stg_transactions') }} t

LEFT JOIN {{ ref('int_customer_accounts') }} origin
    ON t.account_origin_id = origin.account_id

LEFT JOIN {{ ref('int_customer_accounts') }} destination
    ON t.account_destination_id = destination.account_id

LEFT JOIN {{ ref('stg_transaction_types') }} tt
    ON t.transaction_type_id = tt.transaction_type_id

LEFT JOIN {{ ref('stg_branches') }} b
    ON t.branch_id = b.branch_id