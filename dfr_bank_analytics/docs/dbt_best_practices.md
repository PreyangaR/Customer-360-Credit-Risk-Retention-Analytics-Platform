# dbt Best Practices

## Model Organization

The project separates transformations into three layers:

- **Staging:** Standardizes source columns, data types, and duplicate handling.
- **Integration:** Combines and prepares data for downstream analysis.
- **Marts:** Provides business-oriented models for Customer 360, credit risk, retention, and dimensional reporting.

## Sources and Dependencies

Raw source declarations are maintained in `models/sources.yml`. The `source()` and `ref()` functions define dependencies that dbt uses to construct the DAG and determine execution order.

## Testing and Documentation

Schema YAML files document models and define applicable tests. Custom SQL tests validate project-specific business rules and data quality conditions.

The project includes an incremental model demonstration, a snapshot demonstration, a seed file, and a reusable schema naming macro.

The full test suite has a known failure for loan `400080`, where the estimated end date precedes the start date. This exception is documented and retained as a data-quality finding rather than silently corrected.

## Version Control and Security

Project code and documentation are maintained in Git. Credentials, local environment files, and dbt profiles containing connection details should not be committed to version control.

## Limitations

The full test suite includes a known loan date-order exception for loan `400080`. Source data quality issues are documented rather than silently corrected.

The incremental demonstration uses a three-day lookback and can miss late-arriving records older than that window. A production implementation would need an appropriate ingestion timestamp or CDC strategy, periodic reconciliation, and a suitable backfill process.
