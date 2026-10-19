output "kinesis_stream_name" {
  value = aws_kinesis_stream.streaming.name
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.sensor_data.name
}

output "api_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}"
}

output "health_url" {
  value = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${var.aws_region}.amazonaws.com/${aws_api_gateway_stage.prod.stage_name}/health"
}
