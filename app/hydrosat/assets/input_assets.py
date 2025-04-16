import json
from datetime import datetime, timedelta
from io import StringIO

import pandas as pd
from dagster import AssetExecutionContext, asset
from io_resources.s3 import MyS3Config
from parameters import DAILY_PARTITIONS_DEF


@asset(
    partitions_def=DAILY_PARTITIONS_DEF,
)
def previous_day_output(context: AssetExecutionContext, s3: MyS3Config):
    """Fetches previous day's output and returns it as a dictionary."""
    current_partition = context.partition_key
    previous_date_str = (
        datetime.strptime(current_partition, "%Y-%m-%d") - timedelta(days=1)
    ).strftime("%Y-%m-%d")

    s3_client = s3.get_client()
    results = {}
    # Handle missing previous file i.e for day one when no previous file exists
    if current_partition == "2025-04-01":
        context.log.info("First partition - no previous data.")
        return results

    # Read field data
    fields_obj = s3_client.get_object(Bucket=s3.bucket, Key=s3.input_fields_key)
    fields_json = json.loads(fields_obj["Body"].read())
    field_ids = [f["id"] for f in fields_json["fields"]]

    for field_id in field_ids:
        key = (
            f"outputs/{field_id}/{previous_date_str}{field_id}_{previous_date_str}.csv"
        )
        try:
            response = s3_client.get_object(Bucket=s3.bucket, Key=key)
            df = pd.read_csv(StringIO(response["Body"].read().decode("utf-8")))
            results[field_id] = df
            context.log.info(f"Read {key}")
        except s3_client.exceptions.NoSuchKey:
            context.log.warning(f"No data for field {field_id} on {previous_date_str}")
            results[field_id] = None

    return results
