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

# ── VPC Module─────────────────────────
module "vpc" {
  source = "./modules/vpc"

  aws_region = var.aws_region
}

# ── ECS Pentest Module ─────────────────
module "ecs_pentest" {
  source = "./modules/ecs-pentest"

  aws_region         = var.aws_region
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = [
    module.vpc.private_subnet_1_id,
    module.vpc.private_subnet_2_id
  ]

  # These come from Person 1's SNS/SQS terraform
  # Leave as empty string until Person 1 deploys
  pentest_queue_url  = var.pentest_queue_url
  pentest_queue_arn  = var.pentest_queue_arn
  sns_topic_arn      = var.sns_topic_arn

  # These come from Person 1's DynamoDB/S3 terraform
  s3_bucket          = var.s3_bucket
  dynamodb_table     = var.dynamodb_table
  dynamodb_table_arn = var.dynamodb_table_arn
}

# ── CloudWatch Module──────────────────
module "cloudwatch" {
  source           = "./modules/cloudwatch"
  sns_topic_arn    = var.sns_topic_arn
  ec2_instance_id  = ""
  ecs_cluster_name = "securescan-cluster"
  ecs_service_name = "securescan-pentest-service"
  dlq_name         = "securescan-scan-dlq-dev"
}
