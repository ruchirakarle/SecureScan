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


# Person 3 variables by Ruchira
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

variable "dynamodb_table" {
  default = "securescan-history"
}

variable "dynamodb_table_arn" {
  default = ""
}
