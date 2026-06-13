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
  vpc_id                = var.vpc_id
  public_subnet_id      = var.public_subnet_id
  ami_id                = var.ami_id
  key_pair_name         = var.key_pair_name
  dynamodb_table        = var.dynamodb_table
  s3_reports_bucket     = var.s3_bucket
  sqs_sast_queue_url    = aws_sqs_queue.scan_queue.url
  sqs_pentest_queue_url = aws_sqs_queue.pentest_queue.url
  sns_topic_arn         = aws_sns_topic.high_severity_alerts.arn
  sast_scanner_url      = var.sast_scanner_url
}

# ── Lambda SAST Module ─────────────────
module "lambda_sast" {
  source = "./modules/lambda-sast"

  aws_region        = var.aws_region
  dynamodb_table    = var.dynamodb_table
  s3_reports_bucket = var.s3_bucket
  sns_topic_arn     = aws_sns_topic.high_severity_alerts.arn
  sast_queue_arn    = aws_sqs_queue.scan_queue.arn
  sast_scanner_url  = var.sast_scanner_url
}

# ── ECS Pentest Module─────────────────
module "ecs_pentest" {
  source = "./modules/ecs-pentest"

  aws_region         = var.aws_region
  vpc_id             = var.vpc_id
  private_subnet_ids = var.private_subnet_ids

  pentest_queue_url  = var.pentest_queue_url
  pentest_queue_arn  = var.pentest_queue_arn
  sns_topic_arn      = var.sns_topic_arn
  s3_bucket          = var.s3_bucket
  dynamodb_table     = var.dynamodb_table
  dynamodb_table_arn = var.dynamodb_table_arn
}

# ── CloudWatch Module ──────────────────
module "cloudwatch" {
  source           = "./modules/cloudwatch"
  sns_topic_arn    = var.sns_topic_arn
  ec2_instance_id  = ""
  ecs_cluster_name = "securescan-cluster"
  ecs_service_name = "securescan-pentest-service"
  dlq_name         = "securescan-scan-dlq-dev"
}
