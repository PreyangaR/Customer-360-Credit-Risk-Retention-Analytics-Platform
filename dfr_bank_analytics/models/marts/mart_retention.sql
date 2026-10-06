WITH retention_metrics AS (

    SELECT
        customer_id,

        -- Customer profile
        vintage,
        age,
        gender,
        dependents,
        occupation,
        city,
        customer_nw_category,
        branch_code,

        -- Current and historical financial position
        current_balance,
        previous_month_end_balance,
        current_month_balance,
        previous_month_balance,

        -- Credit activity
        current_month_credit,
        previous_month_credit,

        -- Debit activity
        current_month_debit,
        previous_month_debit,

        -- Transaction activity
        last_transaction,

        -- Retention outcome
        churn,

        -- Balance movement
        current_month_balance - previous_month_balance
            AS balance_change,

        ROUND(
            (
                current_month_balance - previous_month_balance
            ) / ABS(previous_month_balance) * 100,
            2
        ) AS balance_change_pct,

        -- Credit movement
        current_month_credit - previous_month_credit
            AS credit_change,

        ROUND(
            (
                current_month_credit - previous_month_credit
            ) / previous_month_credit * 100,
            2
        ) AS credit_change_pct,

        -- Debit movement
        current_month_debit - previous_month_debit
            AS debit_change,

        ROUND(
            (
                current_month_debit - previous_month_debit
            ) / previous_month_debit * 100,
            2
        ) AS debit_change_pct,

        -- Historical transaction recency
        CASE
            WHEN last_transaction IS NULL THEN NULL
            ELSE DATEDIFF(
                'day',
                last_transaction,
                '2019-12-31'
            )
        END AS days_since_last_transaction

    FROM {{ ref('int_churn_customer') }}

),

retention_classification AS (

    SELECT
        *,

        -- Vintage segmentation
        CASE
            WHEN vintage < 365 THEN '< 1 year'
            WHEN vintage < 730 THEN '1 - <2 years'
            WHEN vintage < 1095 THEN '2 - <3 years'
            WHEN vintage < 1460 THEN '3 - <4 years'
            WHEN vintage < 1825 THEN '4 - <5 years'
            ELSE '5+ years'
        END AS vintage_band,

        -- Transaction recency segmentation
        CASE
            WHEN days_since_last_transaction IS NULL
                THEN 'Unknown'
            WHEN days_since_last_transaction <= 30
                THEN '0-30 days'
            WHEN days_since_last_transaction <= 90
                THEN '31-90 days'
            WHEN days_since_last_transaction <= 180
                THEN '91-180 days'
            WHEN days_since_last_transaction <= 365
                THEN '181-365 days'
            ELSE '365+ days'
        END AS transaction_recency_band,

        -- Balance direction
        CASE
            WHEN balance_change > 0
                THEN 'Increasing'
            WHEN balance_change < 0
                THEN 'Decreasing'
            ELSE 'No Change'
        END AS balance_trend,

        -- Retention outcome
        CASE
            WHEN churn = 1 THEN 0
            WHEN churn = 0 THEN 1
        END AS retention_flag,

        CASE
            WHEN churn = 1 THEN 'Churned'
            WHEN churn = 0 THEN 'Retained'
        END AS churn_status

    FROM retention_metrics

)

SELECT
    customer_id,

    -- Customer profile
    vintage,
    vintage_band,
    age,
    gender,
    dependents,
    occupation,
    city,
    customer_nw_category,
    branch_code,

    -- Financial position
    current_balance,
    previous_month_end_balance,
    current_month_balance,
    previous_month_balance,

    -- Financial movement
    balance_change,
    balance_change_pct,

    -- Credit activity
    current_month_credit,
    previous_month_credit,
    credit_change,
    credit_change_pct,

    -- Debit activity
    current_month_debit,
    previous_month_debit,
    debit_change,
    debit_change_pct,

    -- Transaction activity
    last_transaction,
    days_since_last_transaction,
    transaction_recency_band,

    -- Derived behavioral indicator
    balance_trend,

    -- Retention outcome
    churn,
    retention_flag,
    churn_status

FROM retention_classification