SELECT
    BRANCHID   AS branch_id,
    BRANCHNAME AS branch_name,
    ADDRESSID  AS address_id
FROM {{ source('synthetic_finance', 'branches') }}