SELECT DISTINCT
    LOANID            AS loan_id,
    ACCOUNTID         AS account_id,
    LOANSTATUSID      AS loan_status_id,
    PRINCIPALAMOUNT   AS principal_amount,
    INTERESTRATE      AS interest_rate,
    STARTDATE         AS start_date,
    ESTIMATEDENDDATE  AS estimated_end_date
FROM {{ source('synthetic_finance', 'loans') }}