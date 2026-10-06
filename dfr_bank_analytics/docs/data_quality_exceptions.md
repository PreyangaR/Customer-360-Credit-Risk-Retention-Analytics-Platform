# Data Quality Exceptions

## Loan End Date Before Start Date

### Exception

The dbt test `loan_end_date_before_start_date.sql` identifies loans where the estimated end date occurs before the loan start date.

One source-data exception currently exists:

| Loan ID | Account ID | Start Date | Estimated End Date |
|---|---:|---|---|
| 400080 | 201058 | 2026-03-18 15:01:44.338 | 2024-05-30 |

The estimated end date is earlier than the start date, which violates the expected chronological relationship between the two dates.

### Current Treatment

The source value has **not been manually corrected** in the analytics pipeline.

The original source/staging value is preserved, and the dbt data-quality test remains active so that the exception is visible during validation.

This approach avoids silently changing source data without a verified business rule.

### Impact

The exception affects the validity of the date relationship for this individual loan record.

It does not prevent the Credit Risk mart from being built, but downstream users should be aware that this record contains a source-data quality issue.

### Production Remediation

In a production environment, the preferred approach would be to establish a controlled data-quality exception or quarantine workflow.

Potential remediation steps include:

1. Identify the invalid source record.
2. Notify the owning source system or business team.
3. Determine the correct business value.
4. Correct the source record where appropriate.
5. Reprocess the affected data.
6. Verify that the dbt test passes after remediation.

Until the correct business value is confirmed, the analytics pipeline should preserve the source value rather than inventing a replacement.

### dbt Test

The exception is detected by:

`tests/loan_end_date_before_start_date.sql`

The test returns violating records. Therefore:

- **0 rows returned → PASS**
- **1 or more rows returned → ERROR**

The current full test suite has one known failure corresponding to this documented source-data exception.

### Decision

The test remains enabled intentionally.

The goal is not to force the pipeline to show zero errors by weakening or removing the test. The goal is to make source-data quality issues visible, traceable, and actionable.