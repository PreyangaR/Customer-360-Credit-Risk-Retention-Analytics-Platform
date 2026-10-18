# DFR Bank Analytics — dbt Project

This directory contains the **dbt transformation and analytics layer** of the DFR Bank Customer 360, Credit Risk & Retention Analytics Platform.

## Project Overview

DFR Bank uses dbt to transform raw Snowflake data into standardized, integrated, tested, and business-ready analytical models.

The dbt project follows a layered architecture:

```text
Snowflake RAW
      ↓
STAGING
      ↓
INTEGRATION
      ↓
MARTS
      ↓
Power BI
```

## dbt Layers

### Staging

The staging layer standardizes source data and prepares it for downstream transformations.

Responsibilities include:

- column selection and renaming
- data-type standardization
- date parsing
- basic source-data cleaning
- duplicate handling where appropriate
- preserving the source-level grain

Staging models are materialized as **views**.

### Integration

The integration layer combines related source entities and establishes reusable business relationships.

Examples include:

- Customer + customer type + address
- Customer accounts
- Customer loans
- Customer transactions
- Churn customer data

Integration models are materialized as **tables**.

### Marts

The mart layer contains business-ready analytical models designed for reporting and business analysis.

Current marts:

- `mart_customer_360`
- `mart_credit_risk`
- `mart_retention`

Marts are materialized as **tables**.

## Business Marts

### Customer 360

Provides one row per finance-domain customer with consolidated information about:

- customer attributes
- accounts
- balances
- loans
- transactions
- loan status
- customer activity
- transaction flow

### Credit Risk

Provides customer-level analytical risk segmentation using observed loan and account characteristics.

The current project uses:

- overdue loan count
- active loan count
- active loan exposure
- total loan exposure
- account balance
- credit exposure to deposit ratio
- delinquency indicators
- analytical risk segments

The risk tiers are **project-specific analytical segments** and are not intended to represent a regulated banking credit score.

### Retention / Churn

The retention mart is based on the separate churn-data domain.

It provides:

- churn status
- retention flag
- balance changes
- credit changes
- debit changes
- balance trend
- transaction recency
- vintage bands
- recency bands

The churn source contains a different customer-ID domain from the finance source. The project therefore does **not** fabricate a common customer identifier without reliable identity evidence.

## Data Quality

Data quality is implemented using dbt tests including:

- `not_null`
- `unique`
- `relationships`
- `accepted_values`
- custom singular tests
- grain validation tests

The project intentionally keeps source-data quality exceptions visible rather than silently modifying source values.

For example, a known loan record contains an estimated end date earlier than its start date. This is documented in:

```text
docs/data_quality_exceptions.md
```

## Advanced dbt Demonstrations

The project also includes demonstrations of advanced dbt capabilities.

### Incremental Model

`int_transactions_incremental_demo`

Demonstrates:

- incremental materialization
- `unique_key`
- `merge`
- `is_incremental()`
- lookback processing
- handling of late-arriving records

This is an educational/portfolio demonstration rather than the production incremental strategy for the core transaction model.

The incremental demonstration does not guarantee capture of every late-arriving record. Production implementations should consider reliable ingestion timestamps or CDC, periodic reconciliation, and appropriate backfill strategies.

### Snapshot / SCD Type 2

`customer_snapshot_demo`

Demonstrates historical tracking of changing customer attributes using a dbt snapshot.

The demonstration tracks changes to:

- `customer_type`
- `city`

Historical versions are retained instead of overwriting the previous state.

## Seeds

The project contains:

```text
seeds/credit_risk_thresholds.csv
```

This demonstrates the use of dbt seeds for small, version-controlled reference/configuration data.

## Project Structure

```text
dfr_bank_analytics/
│
├── analyses/
│
├── docs/
│   ├── architecture_decisions.md
│   ├── data_quality_exceptions.md
│   ├── ingestion_setup.md
│   ├── dbt_best_practices.md
│   └── performance_and_cost_optimization.md
│
├── macros/
│   └── generate_schema_name.sql
│
├── models/
│   ├── sources.yml
│   │
│   ├── staging/
│   │   ├── schema.yml
│   │   ├── stg_customers.sql
│   │   ├── stg_accounts.sql
│   │   ├── stg_loans.sql
│   │   ├── stg_transactions.sql
│   │   ├── stg_addresses.sql
│   │   ├── stg_branches.sql
│   │   ├── stg_account_types.sql
│   │   ├── stg_account_statuses.sql
│   │   ├── stg_customer_types.sql
│   │   ├── stg_loan_statuses.sql
│   │   ├── stg_transaction_types.sql
│   │   └── stg_churn_prediction.sql
│   │
│   ├── integration/
│   │   ├── schema.yml
│   │   ├── int_customer_core.sql
│   │   ├── int_customer_accounts.sql
│   │   ├── int_customer_loans.sql
│   │   ├── int_customer_transactions.sql
│   │   ├── int_churn_customer.sql
│   │   └── int_transactions_incremental_demo.sql
│   │
│   └── marts/
│       ├── schema.yml
│       ├── mart_customer_360.sql
│       ├── mart_credit_risk.sql
│       ├── mart_retention.sql
│       ├── dim_customer.sql
│       ├── dim_account.sql
│       ├── dim_date.sql
│       ├── dim_branch.sql
│       ├── dim_transaction_type.sql
│       ├── dim_loan_status.sql
│       ├── dim_origin_account.sql
│       ├── dim_destination_account.sql
│       ├── dim_churn_customer.sql
│       ├── fact_transaction.sql
│       ├── fact_loan.sql
│       └── fact_churn.sql
│
├── seeds/
│   └── credit_risk_thresholds.csv
│
├── snapshots/
│   └── customer_snapshot_demo.sql
│
├── tests/
│   ├── credit_risk_grain.sql
│   ├── customer_360_grain.sql
│   ├── loan_end_date_before_start_date.sql
│   └── retention_grain.sql
│
├── dbt_project.yml
└── README.md
```

## Materialization Strategy

| Layer | Materialization | Purpose |
|---|---|---|
| Staging | View | Lightweight source standardization |
| Integration | Table | Reusable integrated datasets |
| Marts | Table | Business-ready analytical datasets |
| Incremental Demo | Incremental | Demonstrate efficient change processing |
| Snapshot | Snapshot | Preserve historical attribute changes |

## Key Architecture Decisions

Important design decisions are documented under:

```text
docs/
```

These include:

- customer identity architecture
- separation of finance and churn customer domains
- source-data quality handling
- analytical risk segmentation
- incremental processing considerations
- S3-to-Snowflake ingestion setup, IAM troubleshooting, and security considerations are documented in [`docs/ingestion_setup.md`](docs/ingestion_setup.md).


## dbt Best Practices

- **Layered transformations:** Separate staging, integration, and mart models to keep transformations organized and maintainable.
- **Source management:** Define raw source tables in `models/sources.yml` and reference models using `ref()`.
- **Data quality:** Use schema tests and custom SQL tests to validate uniqueness, relationships, accepted values, and business rules.
- **Reusable logic:** Use macros for common logic, including the custom schema naming macro.
- **Materialization strategy:** Use views for staging, tables for integration and marts, and an incremental model for the demonstration workload.
- **Version control:** Maintain project code and documentation in Git, while excluding credentials and local environment files.


## Snowflake Cost and Performance Considerations

- **Warehouse sizing:** Used an X-Small Snowflake warehouse (`DFR_WH`) for this development workload.
- **Compute cost control:** Configured automatic suspension after 60 seconds of inactivity and automatic resumption when needed.
- **Model materialization:** Used views for staging and tables for integration and marts, balancing transformation organization with downstream query requirements.
- **Incremental processing:** Built an incremental transaction demo using `transaction_id` as the unique key and a three-day lookback window. This reduces the processing scope but can miss late-arriving records older than the window.
- **Query optimization:** Review Snowflake Query Profile, bytes scanned, execution time, and query history before making performance changes.

These settings provide a baseline for cost management. Query Profile analysis and before/after measurements remain future optimization tasks; no quantified cost savings or query-performance improvements are claimed.


## Running the Project

From the dbt project directory:

```bash
dbt debug
```

Run models:

```bash
dbt run
```

Run tests:

```bash
dbt test
```

Build models and tests together:

```bash
dbt build
```

Run a specific mart and its dependencies:

```bash
dbt build --select +mart_customer_360
```

Run a full refresh of the incremental demonstration:

```bash
dbt run --select int_transactions_incremental_demo --full-refresh
```

Run snapshots:

```bash
dbt snapshot
```

## DAG and dbt Documentation

dbt builds a Directed Acyclic Graph (DAG) from model dependencies declared through `ref()` and `source()`. This determines execution order and helps identify upstream dependencies.

Generate project documentation and lineage metadata using:

```bash
dbt docs generate
dbt docs serve
```

Useful commands for inspecting dependencies and running a selected model with its upstream dependencies:

```bash
dbt ls --select +mart_customer_360
```

The dbt documentation site provides model descriptions, available tests, source information, and lineage where configured.


## Environment and Security

The following should not be committed to Git:

- `.venv/`
- `profiles.yml`
- credentials or secrets
- `target/`
- `dbt_packages/`
- logs

These are excluded through `.gitignore` where applicable.


## Project Purpose

This dbt project demonstrates practical experience with:

- Snowflake
- dbt
- dimensional/business data modeling
- data quality testing
- dependency management
- incremental processing
- SCD Type 2 concepts
- customer analytics
- credit-risk analytics
- retention/churn analytics
- production-oriented data engineering practices