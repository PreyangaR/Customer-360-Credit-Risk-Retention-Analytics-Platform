# Performance and Cost Optimization

## Snowflake Warehouse Configuration

- **Warehouse:** `DFR_WH`
- **Size:** X-Small
- **Auto-suspend:** 60 seconds
- **Auto-resume:** Enabled

These settings were used for the project's development workload. Production sizing should be based on workload concurrency, execution time, resource requirements, and cost.

## dbt Materialization Strategy

- Staging models use views.
- Integration models and marts use tables.
- An incremental transaction model demonstrates merge-based processing using `transaction_id` as the unique key.

Materialization choices should be reviewed against data volume, refresh frequency, and downstream query performance.

## Incremental Processing Trade-offs

The incremental demonstration uses a three-day lookback window based on transaction dates. It limits the processing window but can miss late-arriving records outside that window. A production design could use a reliable ingestion timestamp, CDC, a wider lookback, and periodic reconciliation.

## Snowflake Query Optimization Approach

Before optimizing a query:

1. Inspect its Query Profile and query history.
2. Review execution time and bytes scanned.
3. Identify expensive joins, repeated transformations, and unnecessary scans.
4. Test changes against the original results.
5. Compare performance and cost before claiming an improvement.

## Current Status

The warehouse configuration and materialization choices are documented. Further query-level optimization should be based on measured evidence. No quantified cost savings or performance improvements are claimed.
