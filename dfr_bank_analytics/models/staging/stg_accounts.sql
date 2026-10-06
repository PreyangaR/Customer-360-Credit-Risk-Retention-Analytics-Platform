SELECT DISTINCT
    ACCOUNTID              AS account_id,
    CUSTOMERID             AS customer_id,
    ACCOUNTTYPEID          AS account_type_id,
    ACCOUNTSTATUSID        AS account_status_id,
    BALANCE                AS balance,
    OPENINGDATE::DATE      AS opening_date
FROM {{ source('synthetic_finance', 'accounts') }}