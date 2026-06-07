variable "aws_region"         { type = string }
variable "dynamodb_table"     { type = string }
variable "s3_reports_bucket"  { type = string }
variable "sns_topic_arn"      { type = string }
variable "sast_queue_arn"     { type = string }
variable "sast_scanner_url"   { type = string }