SELECT
    l.loan_id,
    l.account_id,
    a.customer_id,

    a.customer_type,
    a.city,
    a.country,

    l.loan_status_id,
    ls.status_name AS loan_status,

    l.principal_amount,
    l.interest_rate,
    l.start_date,
    l.estimated_end_date

FROM {{ ref('stg_loans') }} l

LEFT JOIN {{ ref('int_customer_accounts') }} a
    ON l.account_id = a.account_id

LEFT JOIN {{ ref('stg_loan_statuses') }} ls
    ON l.loan_status_id = ls.loan_status_id