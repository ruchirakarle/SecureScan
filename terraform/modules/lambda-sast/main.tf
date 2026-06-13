data "aws_iam_role" "lab_role" {
  name = "LabRole"
}

data "archive_file" "sast_lambda" {
  type        = "zip"
  source_dir  = "${path.root}/../../sast-lambda"
  output_path = "${path.module}/sast-lambda.zip"
}

resource "aws_lambda_function" "sast" {
  filename         = data.archive_file.sast_lambda.output_path
  function_name    = "securescan-sast-scanner"
  role             = data.aws_iam_role.lab_role.arn
  handler          = "handler.handler"
  runtime          = "nodejs18.x"
  timeout          = 60
  memory_size      = 512

  source_code_hash = data.archive_file.sast_lambda.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE    = var.dynamodb_table
      S3_REPORTS_BUCKET = var.s3_reports_bucket
      SNS_TOPIC_ARN     = var.sns_topic_arn
      SAST_SCANNER_URL  = var.sast_scanner_url
    }
  }

  tags = { Name = "securescan-sast-lambda" }
}

resource "aws_lambda_event_source_mapping" "sast_sqs" {
  event_source_arn = var.sast_queue_arn
  function_name    = aws_lambda_function.sast.arn
  batch_size       = 1
  enabled          = true
}

resource "aws_cloudwatch_log_group" "sast_lambda" {
  name              = "/aws/lambda/securescan-sast-scanner"
  retention_in_days = 14
}
