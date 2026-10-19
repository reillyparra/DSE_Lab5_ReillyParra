resource "aws_kinesis_stream" "streaming" {
  name        = "${var.project_name}-stream"
  shard_count = 1

  stream_mode_details {
    stream_mode = "PROVISIONED"
  }

  tags = {
    Project = var.project_name
  }
}