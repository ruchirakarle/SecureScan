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

variable "private_subnet_ids" {
  type    = list(string)
  default = []
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
