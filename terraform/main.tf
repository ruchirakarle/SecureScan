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
