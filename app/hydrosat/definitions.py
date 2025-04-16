import pandas as pd
from assets.geospatial_assets import geospatial_partitioned_asset
from assets.input_assets import previous_day_output
from dagster import Definitions, EnvVar
from io_resources.s3 import MyS3Config

defs = Definitions(
    assets=[geospatial_partitioned_asset],
    resources={
        "s3": MyS3Config(
            bucket=EnvVar("S3_BUCKET"),
            region_name=EnvVar("AWS_REGION"),
            input_bbox_key="inputs/bbox.json",
            input_fields_key="inputs/fields.json",
        )
    },
)
