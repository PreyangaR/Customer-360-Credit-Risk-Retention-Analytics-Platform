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