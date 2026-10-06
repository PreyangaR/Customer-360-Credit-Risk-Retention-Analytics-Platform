SELECT DISTINCT 
    CUSTOMER_ID      AS customer_id,
    FIRST_NAME       AS first_name,
    LAST_NAME        AS last_name,
    COALESCE(
    TRY_TO_DATE(NULLIF(TRIM(DATE_OF_BIRTH), 'NaT')),
    TRY_TO_DATE(NULLIF(TRIM(DATE_OF_BIRTH), 'NaT'), 'YYYY/MM/DD'),
    TRY_TO_DATE(NULLIF(TRIM(DATE_OF_BIRTH), 'NaT'), 'DD.MM.YYYY'),
    TRY_TO_DATE(NULLIF(TRIM(DATE_OF_BIRTH), 'NaT'), 'MM.DD.YYYY'),
    TRY_TO_DATE(NULLIF(TRIM(DATE_OF_BIRTH), 'NaT'), 'MM/DD/YYYY'),
    TRY_TO_DATE(NULLIF(TRIM(DATE_OF_BIRTH), 'NaT'), 'DD/MM/YYYY')
) AS date_of_birth,
    CUSTOMER_TYPE_ID AS customer_type_id,
    ADDRESS_ID       AS address_id
FROM {{ source('synthetic_finance', 'customers') }}