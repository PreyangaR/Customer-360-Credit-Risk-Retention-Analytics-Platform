SELECT DISTINCT
    TRANSACTIONID        AS transaction_id,
    ACCOUNTORIGINID      AS account_origin_id,
    ACCOUNTDESTINATIONID AS account_destination_id,
    TRANSACTIONTYPEID    AS transaction_type_id,
    AMOUNT               AS amount,
    TRANSACTIONDATE      AS transaction_date,
    BRANCHID             AS branch_id,
    DESCRIPTION          AS description
FROM {{ source('synthetic_finance', 'transactions') }}