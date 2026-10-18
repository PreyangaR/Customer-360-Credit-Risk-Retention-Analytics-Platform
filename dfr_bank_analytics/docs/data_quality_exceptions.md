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


## Other Data Quality Conditions

### Duplicate Source Records

Duplicate source records were identified and handled in the staging layer where appropriate.

| Source entity | Duplicate IDs identified | Resulting staging rows |
|---|---:|---:|
| Customers | 11 | 1,100 |
| Accounts | 16 | 1,651 |
| Loans | 3 | 330 |
| Transactions | 250 duplicate transaction IDs, representing 500 physical rows | 49,500 |

**Treatment:** Duplicate handling was applied to establish the intended record grain. In a production pipeline, duplicate records with conflicting attribute values should be investigated using an explicit survivorship rule rather than removed blindly.

### Missing Date Values

Some records contain missing or invalid date values.

| Entity | Condition | Observed count |
|---|---|---:|
| Customers | Missing or invalid date of birth | 24 |
| Transactions | Missing transaction date | 990 |
| Loans | Missing start-date key | 6 |
| Loans | Missing estimated end-date key | 6 |
| Churn | Missing last-transaction date | 3,223 |

**Treatment:** Missing dates are retained as missing where a valid date cannot be established. Date-key validation confirmed that non-null source dates were mapped to valid date keys in the tested fact models.

These conditions should be interpreted according to business requirements. A missing date may limit time-based analysis, but it is not automatically evidence that the entire record is invalid.

### Churn Date Parsing

The raw churn dataset contains 28,382 rows. Of these, 25,159 have a valid `LAST_TRANSACTION` date and 3,223 have a missing or unparseable date.

**Treatment:** The date values were not replaced with invented dates. The missing-date condition is documented because it affects transaction-recency and time-based analysis.

### Finance and Churn Customer Identity

The finance and churn datasets use separate customer-ID domains. No reliable identity mapping was established between them.

**Treatment:** The project does not assume that matching-looking customer IDs represent the same person. Finance and churn analyses remain separate unless reliable identity evidence becomes available.

### Production Follow-Up

For a production implementation, the following controls should be considered:

- Monitor duplicate records and unexpected changes in source row counts.
- Track missing and invalid dates by source and reporting period.
- Define explicit rules for resolving conflicting duplicates.
- Route material data-quality failures to an exception or quarantine workflow.
- Reconcile source and downstream record counts after processing.
- Establish a governed identity-resolution process before joining separate customer domains.

These are recommended follow-up controls; they should not be interpreted as proof that a complete automated quarantine or monitoring framework has already been implemented.