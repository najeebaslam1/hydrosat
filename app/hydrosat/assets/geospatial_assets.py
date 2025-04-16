import json
from datetime import datetime, timedelta
from io import StringIO

import pandas as pd
import shapely.geometry
from dagster import AssetExecutionContext, AssetIn, MetadataValue, Output, asset
from io_resources.s3 import MyS3Config
from parameters import DAILY_PARTITIONS_DEF


# @asset(
#     partitions_def=DAILY_PARTITIONS_DEF,
#     ins={"previous_data": AssetIn("previous_day_output")},
# )
@asset(
    partitions_def=DAILY_PARTITIONS_DEF,
)
def geospatial_partitioned_asset(context: AssetExecutionContext, s3: MyS3Config):
    partition_date = context.partition_key
    previous_date_str = (
        datetime.strptime(partition_date, "%Y-%m-%d") - timedelta(days=1)
    ).strftime("%Y-%m-%d")

    s3_client = s3.get_client()

    # Define hypothetical Model parameters for simulation
    max_sunlight_hours = 17  # Arbitrary max sunlight hours
    min_sunlight_hours = 6  # Arbitrary min sunlight hours

    # Load bounding box
    bbox_obj = s3_client.get_object(Bucket=s3.bucket, Key=s3.input_bbox_key)
    bbox_json = json.loads(bbox_obj["Body"].read())
    bbox = shapely.geometry.box(*bbox_json["bbox"])

    # Load field polygons
    fields_obj = s3_client.get_object(Bucket=s3.bucket, Key=s3.input_fields_key)
    fields_json = json.loads(fields_obj["Body"].read())
    fields = [
        {
            "id": field["id"],
            "geometry": shapely.geometry.shape(field["geometry"]),
            "planting_date": field["planting_date"],
        }
        for field in fields_json["fields"]
        if shapely.geometry.shape(field["geometry"]).intersects(bbox)
    ]

    # Simulated processing: generate output for fields planted on or before partition date
    results = []
    for field in fields:
        if field["planting_date"] <= partition_date:
            prev_output_key = f"outputs/{field['id']}/{previous_date_str}/{field['id']}_{previous_date_str}.csv"
            output_key = f"outputs/{field['id']}/{partition_date}/{field['id']}_{partition_date}.csv"
            try:
                # Read and use previous day's output as input of current day processing
                response = s3_client.get_object(Bucket=s3.bucket, Key=prev_output_key)
                csv_content = response["Body"].read().decode("utf-8")
                df = pd.read_csv(StringIO(csv_content))

                previous_water_level = df["current_water_level"].iloc[-1]
                sunlight_hours = df["sunlight_hours"].iloc[-1]
                context.log.info(
                    f"Read {len(df)} rows from previous partition {prev_output_key}"
                )
            except s3_client.exceptions.NoSuchKey:
                # Handle missing previous file i.e for day one when no previous file exists
                print("-- No previous file found, using default values")
                print("-- No previous file found, using default values")
                print("-- No previous file found, using default values")
                print("-- No previous file found, using default values")
                previous_water_level = 0.5  # Simulated water level at start
                sunlight_hours = 12  # Simulated sunlight hours for April 1st
                context.log.info("No previous file found. Using initial data.")

            intersection = field["geometry"].intersection(bbox)
            simulated_value = intersection.area * 0.42  # Arbitrary value

            # Simulate water level and sunlight hours
            current_water_level = (
                previous_water_level * sunlight_hours / simulated_value
            )
            sunlight_range_size = (
                max_sunlight_hours - min_sunlight_hours
            )  # Arbitrary range size for max and min sunlight hours
            sunlight_hours = (
                (sunlight_hours + 1) % sunlight_range_size
            ) + min_sunlight_hours  # Simulated sunlight hours
            results.append(
                {
                    "field_id": field["id"],
                    "date": partition_date,
                    "value": simulated_value,
                    "current_water_level": current_water_level,
                    "sunlight_hours": sunlight_hours,
                }
            )

            # Save result to CSV
            df = pd.DataFrame(results)
            csv_buffer = df.to_csv(index=False)

            s3_client.put_object(Bucket=s3.bucket, Key=output_key, Body=csv_buffer)
        else:
            # Files/polygons out of bounding box
            context.log.warning(
                f"Field {field['id']} has not been under the observation yet!!"
            )

    context.log.info(f"Processed {len(results)} fields for {partition_date}")

    yield Output(
        value=None,
        metadata={"output_file": MetadataValue.path(f"s3://{s3.bucket}/{output_key}")},
    )
