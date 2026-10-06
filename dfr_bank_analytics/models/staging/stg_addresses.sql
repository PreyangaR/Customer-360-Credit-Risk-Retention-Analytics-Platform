SELECT DISTINCT
    ADDRESSID AS address_id,
    STREET    AS street,
    CITY      AS city,
    COUNTRY   AS country
FROM {{ source('synthetic_finance', 'addresses') }}