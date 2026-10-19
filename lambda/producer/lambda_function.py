import json
import os
import time
import random
import boto3

kinesis = boto3.client("kinesis")
stream_name = os.environ["STREAM_NAME"]

def handler(event, context):
    body = event.get("body", "{}")

    if isinstance(body, str):
        body = json.loads(body)

    sensor_id = body.get("sensor_id", "sensor-001")
    bpm = body.get("bpm", random.randint(65, 100))

    record = {
        "sensor_id": sensor_id,
        "bpm": bpm,
        "timestamp": body.get("timestamp", time.strftime("%Y-%m-%dT%H:%M:%SZ"))
    }

    kinesis.put_record(
        StreamName=stream_name,
        Data=json.dumps(record).encode("utf-8"),
        PartitionKey=sensor_id
    )

    return {
        "statusCode": 200,
        "headers": {
            "Content-Type": "application/json"
        },
        "body": json.dumps({
            "message": "Event sent to Kinesis",
            "record": record
        })
    }