
import json
from datetime import datetime, timezone

import boto3
import requests

import os

# Configuration
BUCKET_NAME = os.environ["S3_BUCKET_NAME"]
REGION = "ap-southeast-2"

API_URL = (
    "https://api.worldbank.org/v2/country/IND/"
    "indicator/SP.POP.TOTL?format=json"
)


def main():
    # 1. Extract data from the API
    response = requests.get(API_URL, timeout=30)
    response.raise_for_status()

    api_data = response.json()

    # 2. Validate the basic response structure
    if not isinstance(api_data, list) or len(api_data) != 2:
        raise ValueError("Unexpected World Bank API response structure.")

    metadata, records = api_data

    if not isinstance(records, list):
        raise ValueError("Expected population records in the API response.")

    # 3. Prepare an S3 object key
    now = datetime.now(timezone.utc)
    object_key = (
        f"api_ingestion/world_bank/"
        f"population/year={now:%Y}/month={now:%m}/"
        f"population_{now:%Y%m%dT%H%M%SZ}.json"
    )

    # 4. Upload the API response as JSON to S3
    s3 = boto3.client("s3", region_name=REGION)

    s3.put_object(
        Bucket=BUCKET_NAME,
        Key=object_key,
        Body=json.dumps(api_data, ensure_ascii=False),
        ContentType="application/json",
    )

    print("API ingestion successful.")
    print(f"Records in this API response: {len(records)}")
    print(f"Source metadata: {metadata}")
    print(f"S3 object key: {object_key}")


if __name__ == "__main__":
    main()
