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
