SELECT
    CUSTOMERTYPEID AS customer_type_id,
    TYPENAME       AS type_name
FROM {{ source('synthetic_finance', 'customer_types') }}