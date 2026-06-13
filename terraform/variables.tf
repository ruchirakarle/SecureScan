variable "aws_region" {
  default = "us-east-1"
}

variable "project_name" {
  description = "Project name used as prefix for all resources"
  type        = string
  default     = "securescan"
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}

variable "alert_email" {
  description = "Email address to receive HIGH severity scan alerts"
  type        = string
  default     = "hari.h@northeastern.edu"
}

variable "pentest_queue_url" {
  default = ""
}

variable "pentest_queue_arn" {
  default = ""
}

variable "sns_topic_arn" {
  default = ""
}

variable "s3_bucket" {
  default = "securescan-reports"
}

variable "vpc_id" {
  default = ""
}

variable "private_subnet_ids" {
  type    = list(string)
  default = []
}

variable "dynamodb_table" {
  default = "securescan-history"
}

variable "dynamodb_table_arn" {
  default = ""
}

variable "public_subnet_id" {
  type    = string
  default = ""
}

variable "ami_id" {
  type    = string
  default = ""
}

variable "key_pair_name" {
  type    = string
  default = ""
}

variable "sast_scanner_url" {
  description = "URL of the deployed SAST API server"
  type        = string
  default     = ""
}
