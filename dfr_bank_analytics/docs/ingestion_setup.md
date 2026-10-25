# S3-to-Snowflake Ingestion Setup

## Overview

The DFR Bank analytics pipeline uses AWS S3 to store source CSV files and Snowflake to load and transform the data.

The source files are organized into finance and churn datasets in S3. Snowflake stages provide access to the files, and `COPY INTO` commands load the data into the RAW layer.

## Ingestion Flow

```text
Source CSV files
      |
      v
AWS S3 bucket
      |
      v
Snowflake external stage
      |
      v
COPY INTO
      |
      v
Snowflake RAW tables
```

## IAM Configuration and Troubleshooting

The initial attempt to configure Snowflake access through an IAM role and storage integration encountered an `AssumeRole`/permission error. The troubleshooting process involved reviewing the IAM trust and permission configuration, including JSON policy configuration. Access was restricted by an AWS service control policy.

To complete the development pipeline, an IAM user with access keys was used as a workaround for Snowflake's access to the S3 objects.

This allowed the source files to be loaded into Snowflake. The workaround should not be treated as the preferred long-term authentication design for a production environment.

## Security Considerations

- Never commit AWS access keys, secret keys, Snowflake passwords, or connection profiles to Git.
- Keep credentials outside version-controlled project files.
- Grant only the S3 permissions required for the ingestion process, including appropriate bucket-listing and object-read access.
- Prefer a governed role-based access approach, such as a correctly configured Snowflake storage integration, for production deployment where supported by the AWS organization's policies.
- Grant `s3:ListBucket` on the required bucket and `s3:GetObject` on the required objects, scoped to the necessary resources.
- Avoid granting broader S3 permissions than the ingestion process requires.
- The development workaround used IAM-user access keys. These credentials must not be stored in Git, dbt project files, or documentation. If the credentials are no longer required, revoke them; if they remain in use, rotate and manage them according to the organization's credential policy.
- Review applicable AWS organization policies before attempting role-based access configuration again.

## Loading Data

The Snowflake ingestion workflow uses external stages, CSV file formats, and `COPY INTO` statements to load the source data into the RAW schema.

The RAW layer preserves the loaded source data for downstream dbt transformations and reconciliation.

## Implementation Status

The S3-to-Snowflake loading workflow was completed for the source datasets used in this project. The role-based storage-integration approach encountered an IAM permission restriction, so a direct IAM-user credential workaround was used during development.

The ingestion configuration should be reviewed and strengthened before use in a production banking environment.






## Python REST API to Amazon S3 Ingestion

### 1. Objective

Demonstrate how Python can retrieve data from an external REST API and store the JSON response in Amazon S3.

This is a standalone ingestion proof of concept and does not replace or modify the existing S3-to-Snowflake ingestion process.

### 2. Architecture

World Bank REST API → Python Requests → Response Validation → JSON Serialization → Boto3 → Amazon S3

### 3. Source API

The script retrieves India's total population indicator from the World Bank API.

- **Country code:** `IND`
- **Indicator:** `SP.POP.TOTL`
- **Response format:** JSON
- **Endpoint:** `https://api.worldbank.org/v2/country/IND/indicator/SP.POP.TOTL?format=json`

The API response contains metadata and a list of population records.

### 4. Prerequisites

- Python installed and the project environment configured.
- The `requests` and `boto3` packages installed.
- AWS credentials configured through a supported credential provider.
- An existing S3 bucket in the `ap-southeast-2` region.
- An IAM identity with `s3:PutObject` permission for the designated API-ingestion prefix.

### 5. Dependencies

From the project root, install the required packages in the intended Python environment:

```powershell
python -m pip install requests boto3
```

If these packages are already installed in the project's active environment, reinstalling them is unnecessary.

### 6. Configuration and Security

Before execution:

1. Confirm that the script contains the correct existing S3 bucket name.
2. Confirm that the AWS region is configured as `ap-southeast-2`.
3. Ensure that valid AWS credentials are available in the current environment or through another supported AWS credential provider.
4. Ensure that the IAM identity has permission to upload objects to the required S3 prefix.

The script should not contain hardcoded AWS access keys or secret access keys.

Do not commit credentials, secret values, or credential-containing environment files to GitHub. The dedicated IAM policy should grant only the permissions required for this ingestion task.

### 7. Execution

From the repository root, run:

```powershell
python dfr_bank_analytics/ingestion/ingest_world_bank_to_s3.py
```

Run this command from the repository root so the script path matches the project structure.

The script sends a request to the API, validates the basic response structure, creates an S3 object key, and uploads the JSON response.

### 8. S3 Destination

Objects are stored under the following prefix:

`api_ingestion/world_bank/population/`

The complete key follows this pattern:

`api_ingestion/world_bank/population/year=YYYY/month=MM/population_YYYYMMDDTHHMMSSZ.json`

The year, month, and timestamp components organize outputs by ingestion time. Each run creates a new timestamped object rather than intentionally overwriting a fixed filename.

### 9. Validation Procedure

After running the script, verify the following:

1. The script reports successful API ingestion.
2. The record count and source metadata are printed.
3. An S3 object key is displayed.
4. The object exists in the expected S3 prefix in the AWS console.
5. The uploaded object contains valid JSON.

A successful upload confirms that the API extraction and S3 storage steps worked for that run. It does not establish that all API pages were retrieved or that the data is integrated into the downstream analytics pipeline.

### 10. Troubleshooting

**AWS credentials not found or authentication failure**

- Confirm that credentials are configured in the current PowerShell session or another supported credential provider.
- Verify that the intended AWS identity is being used.
- Do not paste credentials into source code or commit them to GitHub.

**Access denied during upload**

- Verify the IAM policy attached to the active identity.
- Confirm that the policy permits `s3:PutObject` for the correct bucket and API-ingestion prefix.
- Confirm that the script uses the expected bucket name and object key.

**API request failure**

- Check network connectivity and the endpoint.
- Confirm that the HTTP response is successful.
- Review the exception reported by the script.

**S3 object not found**

- Check the object key printed by the script.
- Navigate to the corresponding year and month prefix in the S3 console.
- Confirm that the upload completed without an exception.

### 11. Current Limitations

- Only the first API response page is retrieved; pagination is not implemented.
- Retry and exponential backoff logic are not implemented.
- The script runs manually and has no automated schedule.
- Monitoring, alerting, and automated data-quality reporting are not implemented.
- No downstream Snowflake ingestion or dbt transformation is configured for this API output.

These limitations are documented to distinguish the proof of concept from a production ingestion service.

### 12. Relationship to the Existing Pipeline

The two ingestion paths are separate:

**Primary DFR Bank analytics pipeline**

Source CSV files → Amazon S3 → Snowflake RAW → dbt staging → dbt integration → reporting models and star schema → Power BI

**Standalone API-ingestion proof of concept**

World Bank REST API → Python Requests → Boto3 → Amazon S3

The API proof of concept demonstrates ingestion from an external API. It does not currently feed the primary Snowflake, dbt, or Power BI workflow.