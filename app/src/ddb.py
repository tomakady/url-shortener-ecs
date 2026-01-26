import os, boto3

# TABLE_NAME must be provided via ECS task environment
_table_name = os.environ["TABLE_NAME"]
_dynamodb_endpoint = os.environ.get("DYNAMODB_ENDPOINT_URL")

if _dynamodb_endpoint:
    dynamodb = boto3.resource("dynamodb", endpoint_url=_dynamodb_endpoint)
else:
    dynamodb = boto3.resource("dynamodb")

_table = dynamodb.Table(_table_name)


def put_mapping(short_id: str, url: str):
    _table.put_item(Item={"id": short_id, "url": url})

def get_mapping(short_id: str):
    resp = _table.get_item(Key={"id": short_id})
    return resp.get("Item")