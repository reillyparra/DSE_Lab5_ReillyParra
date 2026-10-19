data "archive_file" "producer_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/producer/lambda_function.py"
  output_path = "${path.module}/producer.zip"
}

data "archive_file" "processor_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/processor/lambda_function.py"
  output_path = "${path.module}/processor.zip"
}

resource "aws_lambda_function" "producer" {
  function_name = "${var.project_name}-producer"
  role          = data.aws_iam_role.lambda_role.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.producer_zip.output_path
  source_code_hash = data.archive_file.producer_zip.output_base64sha256

  timeout = 15

  environment {
    variables = {
      STREAM_NAME = aws_kinesis_stream.streaming.name
    }
  }
}

resource "aws_lambda_function" "processor" {
  function_name = "${var.project_name}-processor"
  role          = data.aws_iam_role.lambda_role.arn
  handler       = "lambda_function.handler"
  runtime       = "python3.12"

  filename         = data.archive_file.processor_zip.output_path
  source_code_hash = data.archive_file.processor_zip.output_base64sha256

  timeout = 30

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.sensor_data.name
    }
  }
}

resource "aws_lambda_event_source_mapping" "kinesis" {
  event_source_arn  = aws_kinesis_stream.streaming.arn
  function_name     = aws_lambda_function.processor.arn
  starting_position = "LATEST"

  batch_size                         = 10
  maximum_batching_window_in_seconds = 2


}