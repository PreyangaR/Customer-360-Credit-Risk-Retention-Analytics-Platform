SELECT
    LOANSTATUSID AS loan_status_id,
    STATUSNAME   AS status_name
FROM {{ source('synthetic_finance', 'loan_statuses') }}
