{% snapshot customer_snapshot_demo %}

{{
    config(
        target_schema='STAGING',
        unique_key='customer_id',
        strategy='check',
        check_cols=['customer_type', 'city']
    )
}}

SELECT
    customer_id,
    customer_type,
    city
FROM DFR_BANK.RAW.CUSTOMER_SNAPSHOT_DEMO

{% endsnapshot %}