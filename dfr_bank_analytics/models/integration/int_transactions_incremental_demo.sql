{{ config(
    materialized='incremental',
    unique_key='transaction_id',
    incremental_strategy='merge'
) }}

SELECT
    transaction_id,
    account_origin_id,
    account_destination_id,
    transaction_type_id,
    amount,
    transaction_date,
    branch_id,
    description

FROM {{ ref('stg_transactions') }}

{% if is_incremental() %}

WHERE
    transaction_date >= (
        SELECT DATEADD(
            day,
            -3,
            MAX(transaction_date)
        )
        FROM {{ this }}
    )

    OR transaction_date IS NULL

{% endif %}