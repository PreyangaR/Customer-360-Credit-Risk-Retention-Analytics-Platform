SELECT
    loan_id,
    start_date,
    estimated_end_date
FROM {{ ref('stg_loans') }}
WHERE estimated_end_date < start_date