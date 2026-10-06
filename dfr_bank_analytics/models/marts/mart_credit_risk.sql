WITH account_metrics AS (

    SELECT
        customer_id,
        -- Balance across all account records
        SUM(balance) AS total_account_balance,

        -- Balance associated with currently active accounts
        SUM(
            CASE
                WHEN account_status = 'Active'
                THEN balance
                ELSE 0
            END
        ) AS active_deposit_balance,

        -- Number of currently active accounts
        COUNT_IF(account_status = 'Active') AS active_account_count
    FROM {{ ref('int_customer_accounts') }}
    GROUP BY customer_id

),




loan_metrics AS (

    SELECT
        customer_id,
        -- Overall loan exposure
        COUNT(DISTINCT loan_id) AS total_loans_borrowed,
        SUM(principal_amount) AS total_loan_exposure,

        -- Active loan exposure
        SUM(
            CASE
                WHEN loan_status = 'Active'
                THEN principal_amount
                ELSE 0
            END
        ) AS active_loan_exposure,

        -- Overdue loan exposure
        SUM(
            CASE
                WHEN loan_status = 'Overdue'
                THEN principal_amount
                ELSE 0
            END
        ) AS overdue_loan_exposure,

        -- Loan counts by status
        COUNT_IF(loan_status = 'Active') AS active_loan_count,
        COUNT_IF(loan_status = 'Overdue') AS overdue_loan_count,
        COUNT_IF(loan_status = 'Paid Off') AS paid_off_loan_count,

        -- Interest-rate metrics
        AVG(interest_rate) AS average_interest_rate,
        MAX(interest_rate) AS max_interest_rate

    FROM {{ ref('int_customer_loans') }}
    GROUP BY customer_id

),





risk_joined AS (

    SELECT
        c.customer_id,
        c.customer_type,
        c.city AS customer_city,
        c.country AS customer_country,

        -- Account metrics
        COALESCE(a.total_account_balance, 0) AS total_account_balance,
        COALESCE(a.active_deposit_balance, 0) AS active_deposit_balance,
        COALESCE(a.active_account_count, 0) AS active_account_count,

        -- Loan metrics
        COALESCE(l.total_loans_borrowed, 0) AS total_loans_borrowed,
        COALESCE(l.total_loan_exposure, 0) AS total_loan_exposure,
        COALESCE(l.active_loan_exposure, 0) AS active_loan_exposure,
        COALESCE(l.overdue_loan_exposure, 0) AS overdue_loan_exposure,
        COALESCE(l.active_loan_count, 0) AS active_loan_count,
        COALESCE(l.overdue_loan_count, 0) AS overdue_loan_count,
        COALESCE(l.paid_off_loan_count, 0) AS paid_off_loan_count,
        COALESCE(l.average_interest_rate, 0) AS average_interest_rate,
        COALESCE(l.max_interest_rate, 0) AS max_interest_rate

    FROM {{ ref('int_customer_core') }} c

    LEFT JOIN account_metrics a
        ON c.customer_id = a.customer_id

    LEFT JOIN loan_metrics l
        ON c.customer_id = l.customer_id

),







risk_metrics AS (

    SELECT
        *,

        -- Active loan exposure relative to active deposit balance
        CASE
            WHEN active_deposit_balance = 0 THEN NULL
            ELSE ROUND(
                active_loan_exposure / active_deposit_balance,
                2
            )
        END AS credit_exposure_to_deposit_ratio,

        -- Customer has at least one overdue loan
        CASE
            WHEN overdue_loan_count > 0 THEN 1
            ELSE 0
        END AS is_delinquent,

        -- Customer has at least one active loan
        CASE
            WHEN active_loan_count > 0 THEN TRUE
            ELSE FALSE
        END AS has_active_loan,

        -- Customer has at least one overdue loan
        CASE
            WHEN overdue_loan_count > 0 THEN TRUE
            ELSE FALSE
        END AS has_overdue_loan

    FROM risk_joined

),





risk_classification AS (

    SELECT
        *,

        CASE
            WHEN overdue_loan_count >= 2
                THEN 'Tier 4 - Critical Risk'

            WHEN overdue_loan_count = 1
                THEN 'Tier 3 - High Risk'

            WHEN active_loan_count >= 2
                 OR active_loan_exposure >= 100000
                THEN 'Tier 2 - Moderate Risk'

            ELSE 'Tier 1 - Lower Observed Risk'
        END AS credit_risk_segment

    FROM risk_metrics

)






SELECT
    customer_id,

    -- Customer attributes
    customer_type,
    customer_city,
    customer_country,

    -- Account metrics
    total_account_balance,
    active_deposit_balance,
    active_account_count,

    -- Loan metrics
    total_loans_borrowed,
    total_loan_exposure,
    active_loan_exposure,
    overdue_loan_exposure,

    active_loan_count,
    overdue_loan_count,
    paid_off_loan_count,

    average_interest_rate,
    max_interest_rate,

    -- Derived indicators
    credit_exposure_to_deposit_ratio,
    is_delinquent,
    has_active_loan,
    has_overdue_loan,

    -- Final business classification
    credit_risk_segment

FROM risk_classification