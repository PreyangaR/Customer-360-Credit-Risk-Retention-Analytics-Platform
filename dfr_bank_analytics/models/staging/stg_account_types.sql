SELECT
    ACCOUNTTYPEID AS account_type_id,
    TYPENAME      AS type_name
FROM {{ source('synthetic_finance', 'account_types') }}