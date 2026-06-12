data "archive_file" "sast_lambda" {
  type        = "zip"
  source_dir  = "${path.root}/../../sast-lambda"
  output_path = "${path.module}/sast-lambda.zip"
}

resource "aws_iam_role" "sast_lambda" {
  name = "securescan-sast-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "lambda.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "sast_lambda" {
  name = "securescan-sast-lambda-policy"
  role = aws_iam_role.sast_lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem", "dynamodb:GetItem", "dynamodb:PutItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/${var.dynamodb_table}*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject", "s3:GetObject"]
        Resource = "arn:aws:s3:::${var.s3_reports_bucket}/*"
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = var.sns_topic_arn
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage", "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = var.sast_queue_arn
      }
    ]
  })
}

resource "aws_lambda_function" "sast" {
  filename         = data.archive_file.sast_lambda.output_path
  function_name    = "securescan-sast-scanner"
  role             = aws_iam_role.sast_lambda.arn
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
