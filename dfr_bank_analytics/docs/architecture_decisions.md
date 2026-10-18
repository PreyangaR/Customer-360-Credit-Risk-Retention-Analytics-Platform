# Architecture Decisions

## Customer Identity Across Source Domains

### Decision

The finance and churn datasets are treated as separate customer identity domains.

The finance dataset uses its own `customer_id`, while the churn dataset uses a different `customer_id` domain. The two identifiers are not assumed to represent the same customer simply because both columns are named `customer_id`.

### Rationale

The available attributes do not provide sufficient deterministic evidence to establish a reliable person-level mapping between the two datasets.

For example, city or branch information alone is not sufficient to establish that two records represent the same individual.

Creating a synthetic `DFR_CUSTOMER_ID` mapping without reliable evidence would create false customer relationships and could lead to incorrect Customer 360 and retention analysis.

### Current Architecture

Finance domain:

RAW → STAGING → INTEGRATION → Customer 360 / Credit Risk

Churn domain:

RAW → STAGING → INTEGRATION → Retention Analytics

### Future Enterprise Architecture

If a reliable cross-source customer identifier or customer cross-reference table becomes available, the platform could introduce a conformed `DFR_CUSTOMER_ID` and map source-system customer identifiers to it.

Until then, source-specific customer identities are preserved.


## Data Layer Separation

### Decision

The platform separates data into RAW, STAGING, INTEGRATION, and MART layers.

### Rationale

Each layer has a distinct responsibility:

- **RAW:** Preserve ingested source data.
- **STAGING:** Standardize column names, data types, dates, and source records.
- **INTEGRATION:** Combine related entities and establish reusable business relationships.
- **MART:** Provide business-ready models for reporting and analysis.

This separation improves maintainability, traceability, and the ability to investigate data-quality issues.

## Dimensional Modeling for Power BI

### Decision

Power BI uses dimensional models materialized in Snowflake, including fact and dimension tables, rather than relying solely on wide analytical marts.

### Rationale

Fact tables represent measurable business events at a defined grain. Dimension tables provide descriptive context for filtering and grouping those events.

The model supports transaction, loan, customer, and churn analysis while keeping relationships explicit.

Role-playing account dimensions are used for transaction origin and destination accounts. The loan end-date relationship to the date dimension is inactive because the same date dimension is also used for other date roles.

## Data Quality and Source Preservation

### Decision

Known source-data quality exceptions are documented and tested rather than silently corrected without a verified business rule.

### Rationale

Automatically inventing replacement values or removing records can distort financial and business reporting.

The loan record with an estimated end date earlier than its start date remains visible through a dbt test. Missing dates and duplicate records are handled according to their specific transformation requirements, with known exceptions documented separately.

## Credit Risk Segmentation

### Decision

The credit-risk mart uses transparent, rule-based analytical segments derived from observed loan and account characteristics.

### Rationale

The rules make the segmentation understandable and reproducible. The thresholds are project-specific and are not represented as a regulated credit score or a validated default-prediction model.

The segments support portfolio analysis and should not be treated as an automated lending decision.

## Incremental Processing Demonstration

### Decision

An incremental transaction model is maintained as a separate educational demonstration rather than being presented as the production ingestion strategy for the core transaction model.

### Rationale

The demonstration uses a unique transaction key, merge behavior, and a three-day lookback window. Late-arriving records older than the lookback window may be missed.

A production implementation should evaluate ingestion timestamps or CDC, periodic reconciliation, and appropriate backfill strategies.

## Ingestion and Security

### Decision

The S3-to-Snowflake ingestion setup and its IAM troubleshooting history are documented separately in `docs/ingestion_setup.md`.

### Rationale

Keeping operational setup and security details in a dedicated document makes the architecture decisions easier to review while preserving the implementation history and known limitations.