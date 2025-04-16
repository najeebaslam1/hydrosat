import json
from datetime import datetime, timedelta
from io import StringIO

import boto3
import pandas as pd
import shapely.geometry
from dagster import (
    AssetExecutionContext,
    ConfigurableResource,
    DailyPartitionsDefinition,
    Definitions,
    EnvVar,
    Output,
    asset,
)
from dagster_aws.s3 import S3Resource


class MyS3Config(ConfigurableResource):
    bucket: str
    region_name: str
    # Define paths in S3

    input_bbox_key: str
    input_fields_key: str

    # bbox_key = f"inputs/bbox.json"
    # fields_key = f"inputs/fields.json"

    def get_client(self):
        return boto3.client("s3", region_name=self.region_name)


@asset(partitions_def=DailyPartitionsDefinition(start_date="2025-04-01"))
def previous_day_output(context: AssetExecutionContext, s3: MyS3Config):
    partition_date = datetime.strptime(context.partition_key, "%Y-%m-%d")
    previous_date_str = (partition_date - timedelta(days=1)).strftime("%Y-%m-%d")

    s3_client = s3.get_client()
    previous_outputs = {}

    for field_id in [
        "field1",
        "field2",
    ]:  # Replace with dynamic logic or pre-defined list
        prev_key = f"outputs/{field_id}/{field_id}_{previous_date_str}.csv"
        try:
            response = s3_client.get_object(Bucket=s3.bucket, Key=prev_key)
            df = pd.read_csv(StringIO(response["Body"].read().decode("utf-8")))
            previous_outputs[field_id] = {
                "water": df["current_water_level"].iloc[-1],
                "sun": df["sunlight_hours"].iloc[-1],
            }
            context.log.info(f"Loaded previous data for {field_id}")
        except s3_client.exceptions.NoSuchKey:
            previous_outputs[field_id] = {
                "water": 0.5,
                "sun": 12,
            }
            context.log.info(f"No previous data found for {field_id}, using defaults.")

    yield Output(previous_outputs)


@asset(
    partitions_def=DailyPartitionsDefinition(start_date="2025-04-01"),
)
def geospatial_partitioned_asset(
    context: AssetExecutionContext, s3: MyS3Config, previous_day_output: dict
):
    partition_date = context.partition_key
    s3_client = s3.get_client()

    bbox = shapely.geometry.box(
        *json.loads(
            s3_client.get_object(Bucket=s3.bucket, Key=s3.input_bbox_key)["Body"].read()
        )["bbox"]
    )

    fields = [
        {
            "id": field["id"],
            "geometry": shapely.geometry.shape(field["geometry"]),
            "planting_date": field["planting_date"],
        }
        for field in json.loads(
            s3_client.get_object(Bucket=s3.bucket, Key=s3.input_fields_key)[
                "Body"
            ].read()
        )["fields"]
        if shapely.geometry.shape(field["geometry"]).intersects(bbox)
    ]

    results = []
    for field in fields:
        if field["planting_date"] <= partition_date:
            prev_data = previous_day_output.get(field["id"], {"water": 0.5, "sun": 12})
            previous_water_level = prev_data["water"]
            sunlight_hours = prev_data["sun"]

            intersection = field["geometry"].intersection(bbox)
            simulated_value = intersection.area * 0.42

            current_water_level = (
                previous_water_level * sunlight_hours / simulated_value
            )
            sunlight_hours = (sunlight_hours + 1) % 11 + 6

            results.append(
                {
                    "field_id": field["id"],
                    "date": partition_date,
                    "value": simulated_value,
                    "current_water_level": current_water_level,
                    "sunlight_hours": sunlight_hours,
                }
            )

            output_key = f"outputs/{field['id']}/{field['id']}_{partition_date}.csv"
            df = pd.DataFrame(results)
            s3_client.put_object(
                Bucket=s3.bucket, Key=output_key, Body=df.to_csv(index=False)
            )

    yield Output(value=None, metadata={"partition_date": partition_date})


defs = Definitions(
    assets=[previous_day_output, geospatial_partitioned_asset],
    resources={
        "s3": MyS3Config(
            bucket=EnvVar("S3_BUCKET"),
            region_name=EnvVar("AWS_REGION"),
            input_bbox_key="inputs/bbox.json",
            input_fields_key="inputs/fields.json",
        )
    },
)
