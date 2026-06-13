terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# ── EC2 Backend Module ─────────────────
module "ec2" {
  source = "./modules/ec2"

  aws_region            = var.aws_region
  vpc_id                = aws_vpc.securescan.id
  public_subnet_id      = aws_subnet.public_1.id
  ami_id                = var.ami_id
  key_pair_name         = var.key_pair_name
  dynamodb_table        = aws_dynamodb_table.scans.name
  s3_reports_bucket     = aws_s3_bucket.reports.bucket
  sqs_sast_queue_url    = aws_sqs_queue.scan_queue.url
  sqs_pentest_queue_url = aws_sqs_queue.pentest_queue.url
  sns_topic_arn         = aws_sns_topic.high_severity_alerts.arn
  sast_scanner_url      = var.sast_scanner_url
}

# ── Lambda SAST Module ─────────────────
module "lambda_sast" {
  source = "./modules/lambda-sast"

  aws_region        = var.aws_region
  dynamodb_table    = aws_dynamodb_table.scans.name
  s3_reports_bucket = aws_s3_bucket.reports.bucket
  sns_topic_arn     = aws_sns_topic.high_severity_alerts.arn
  sast_queue_arn    = aws_sqs_queue.scan_queue.arn
  sast_scanner_url  = var.sast_scanner_url
}

# ── ECS Pentest Module ─────────────────
module "ecs_pentest" {
  source             = "./modules/ecs-pentest"
  aws_region         = var.aws_region
  vpc_id             = aws_vpc.securescan.id
  private_subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  pentest_queue_url  = aws_sqs_queue.pentest_queue.url
  pentest_queue_arn  = aws_sqs_queue.pentest_queue.arn
  sns_topic_arn      = aws_sns_topic.high_severity_alerts.arn
  s3_bucket          = aws_s3_bucket.reports.bucket
  dynamodb_table     = aws_dynamodb_table.scans.name
  dynamodb_table_arn = aws_dynamodb_table.scans.arn
}

# ── CloudWatch Module ──────────────────
module "cloudwatch" {
  source           = "./modules/cloudwatch"
  sns_topic_arn    = aws_sns_topic.high_severity_alerts.arn
  ec2_instance_id  = module.ec2.instance_id
  ecs_cluster_name = "securescan-cluster"
  ecs_service_name = "securescan-pentest-service"
  dlq_name         = aws_sqs_queue.scan_dlq.name
}
