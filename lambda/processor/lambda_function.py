import json
import os
import base64
import boto3

dynamodb = boto3.resource("dynamodb")
table = dynamodb.Table(os.environ["TABLE_NAME"])

redshift = boto3.client("redshift-data")

WORKGROUP = os.environ["REDSHIFT_WORKGROUP"]
DATABASE = os.environ["REDSHIFT_DATABASE"]

def ensure_table():
    redshift.execute_statement(
        WorkgroupName=WORKGROUP,
        Database=DATABASE,
        Sql="""
        CREATE TABLE IF NOT EXISTS sensor_data (
            sensor_id VARCHAR(100),
            timestamp VARCHAR(100),
            bpm INTEGER
        )
        """
    )

def handler(event, context):
    processed = 0
    rejected = 0

    try:
        ensure_table()
    except Exception as error:
        print("Redshift table creation warning:", str(error))

    for record in event.get("Records", []):
        try:
            payload = base64.b64decode(record["kinesis"]["data"]).decode("utf-8")
            data = json.loads(payload)

            sensor_id = data.get("sensor_id")
            bpm = data.get("bpm")
            timestamp = data.get("timestamp")

            if not sensor_id or not timestamp or not isinstance(bpm, (int, float)):
                rejected += 1
                continue

            if bpm < 30 or bpm > 220:
                rejected += 1
                continue

            table.put_item(
                Item={
                    "sensor_id": sensor_id,
                    "timestamp": timestamp,
                    "bpm": int(bpm),
                    "status": "valid"
                }
            )

            processed += 1

        except Exception as error:
            rejected += 1
            print("Processing error:", str(error))

    print(json.dumps({
        "processed": processed,
        "rejected": rejected
    }))

    return {
        "processed": processed,
        "rejected": rejected
    }