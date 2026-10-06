WITH account_summary AS (

    SELECT
        customer_id,
        COUNT(DISTINCT account_id) AS account_count,
        SUM(balance) AS total_account_balance,
        COUNT_IF(account_status = 'Active') AS active_account_count,
        COUNT_IF(account_status = 'Inactive') AS inactive_account_count,
        COUNT_IF(account_status = 'Closed') AS closed_account_count
    FROM {{ ref('int_customer_accounts') }}
    GROUP BY customer_id

),



loan_summary AS (

    SELECT
        customer_id,
        COUNT(DISTINCT loan_id) AS loan_count,
        SUM(principal_amount) AS total_loan_principal,
        COUNT_IF(loan_status = 'Active') AS active_loan_count,
        COUNT_IF(loan_status = 'Paid Off') AS paid_off_loan_count,
        COUNT_IF(loan_status = 'Overdue') AS overdue_loan_count
    FROM {{ ref('int_customer_loans') }}
    GROUP BY customer_id

),


origin_transaction_summary AS (

    SELECT
        origin_customer_id AS customer_id,
        COUNT(DISTINCT transaction_id) AS origin_transaction_count,
        SUM(amount) AS origin_transaction_amount
    FROM {{ ref('int_customer_transactions') }}
    WHERE origin_customer_id IS NOT NULL
    GROUP BY origin_customer_id

),




destination_transaction_summary AS (

    SELECT
        destination_customer_id AS customer_id,
        COUNT(DISTINCT transaction_id) AS destination_transaction_count,
        SUM(amount) AS destination_transaction_amount
    FROM {{ ref('int_customer_transactions') }}
    WHERE destination_customer_id IS NOT NULL
    GROUP BY destination_customer_id

)

SELECT
    c.customer_id,
    c.first_name,
    c.last_name,
    c.date_of_birth,

    DATEDIFF(
        'year',
        c.date_of_birth,
        CURRENT_DATE()
    ) AS customer_age,

    c.customer_type,
    c.city,
    c.country,



    COALESCE(a.account_count, 0) AS account_count,
    COALESCE(a.total_account_balance, 0) AS total_account_balance,
    COALESCE(a.active_account_count, 0) AS active_account_count,
    COALESCE(a.inactive_account_count, 0) AS inactive_account_count,
    COALESCE(a.closed_account_count, 0) AS closed_account_count,


    COALESCE(l.loan_count, 0) AS loan_count,
    COALESCE(l.total_loan_principal, 0) AS total_loan_principal,
    COALESCE(l.active_loan_count, 0) AS active_loan_count,
    COALESCE(l.paid_off_loan_count, 0) AS paid_off_loan_count,
    COALESCE(l.overdue_loan_count, 0) AS overdue_loan_count,


    COALESCE(o.origin_transaction_count, 0) AS origin_transaction_count,
    COALESCE(o.origin_transaction_amount, 0) AS origin_transaction_amount,


    COALESCE(d.destination_transaction_count, 0) AS destination_transaction_count,
    COALESCE(d.destination_transaction_amount, 0) AS destination_transaction_amount,


    /* =========================
       DERIVED TRANSACTION METRICS
       ========================= */

    COALESCE(o.origin_transaction_count, 0) + COALESCE(d.destination_transaction_count, 0) AS total_transaction_count,
    COALESCE(o.origin_transaction_amount, 0) + COALESCE(d.destination_transaction_amount, 0) AS total_transaction_amount,
    COALESCE(d.destination_transaction_amount, 0) - COALESCE(o.origin_transaction_amount, 0) AS net_transaction_flow,


    /* =========================
       CUSTOMER / CREDIT FINDINGS
       ========================= */

    CASE
        WHEN COALESCE(l.active_loan_count, 0) > 0
        THEN TRUE
        ELSE FALSE
    END AS has_active_loan,

    CASE
        WHEN COALESCE(l.overdue_loan_count, 0) > 0
        THEN TRUE
        ELSE FALSE
    END AS has_overdue_loan,


    /* =========================
       LOAN-TO-BALANCE RATIO
       ========================= */

    CASE
        WHEN COALESCE(a.total_account_balance, 0) = 0
        THEN NULL

        ELSE ROUND(
            COALESCE(l.total_loan_principal, 0)
            / a.total_account_balance,
            2
        )
    END AS loan_to_account_balance_ratio,


    /* =========================
       SIMPLE ACTIVITY CLASSIFICATION
       ========================= */

    CASE
        WHEN
            COALESCE(o.origin_transaction_count, 0) + COALESCE(d.destination_transaction_count, 0) = 0
        THEN 'Inactive'

        WHEN
            COALESCE(o.origin_transaction_count, 0) + COALESCE(d.destination_transaction_count, 0) < 10
        THEN 'Low Activity'

        WHEN
            COALESCE(o.origin_transaction_count, 0) + COALESCE(d.destination_transaction_count, 0) < 50
        THEN 'Medium Activity'

        ELSE 'High Activity'
    END AS customer_activity_level,


    /* =========================
       SIMPLE LOAN STATUS
       ========================= */

    CASE
        WHEN COALESCE(l.overdue_loan_count, 0) > 0
        THEN 'Overdue'

        WHEN COALESCE(l.active_loan_count, 0) > 0
        THEN 'Active'

        WHEN COALESCE(l.paid_off_loan_count, 0) > 0
        THEN 'Paid Off'

        ELSE 'No Loan'
    END AS loan_status_summary

FROM {{ ref('int_customer_core') }} c

LEFT JOIN account_summary a
    ON c.customer_id = a.customer_id

LEFT JOIN loan_summary l
    ON c.customer_id = l.customer_id

LEFT JOIN origin_transaction_summary o
    ON c.customer_id = o.customer_id

LEFT JOIN destination_transaction_summary d
    ON c.customer_id = d.customer_id