import boto3
from dagster import ConfigurableResource


class MyS3Config(ConfigurableResource):
    bucket: str
    region_name: str
    input_bbox_key: str
    input_fields_key: str

    # bbox_key = f"inputs/bbox.json"
    # fields_key = f"inputs/fields.json"

    def get_client(self):
        return boto3.client("s3", region_name=self.region_name)
