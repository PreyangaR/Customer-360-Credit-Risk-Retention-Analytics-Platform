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
│   └── data_quality_exceptions.md
│
├── macros/
│   └── generate_schema_name.sql
│
├── models/
│   ├── staging/
│   ├── integration/
│   └── marts/
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