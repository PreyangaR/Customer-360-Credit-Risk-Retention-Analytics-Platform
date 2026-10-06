SELECT
    ACCOUNTSTATUSID AS account_status_id,
    STATUSNAME      AS status_name
FROM {{ source('synthetic_finance', 'account_statuses') }}