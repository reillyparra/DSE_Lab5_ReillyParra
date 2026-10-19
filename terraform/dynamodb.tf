resource "aws_dynamodb_table" "sensor_data" {
  name         = "${var.project_name}-sensor-data"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "sensor_id"
  range_key    = "timestamp"

  attribute {
    name = "sensor_id"
    type = "S"
  }

  attribute {
    name = "timestamp"
    type = "S"
  }

  tags = {
    Project = var.project_name
  }
}