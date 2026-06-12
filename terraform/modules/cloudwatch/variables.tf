variable "sns_topic_arn" {
  type        = string
  description = "SNS topic ARN for alerts"
}

variable "ec2_instance_id" {
  type        = string
  description = "EC2 instance ID"
  default     = ""
}

variable "ecs_cluster_name" {
  type        = string
  description = "ECS cluster name"
  default     = "securescan-cluster"
}

variable "ecs_service_name" {
  type        = string
  description = "ECS pentest service name"
  default     = "securescan-pentest-service"
}

variable "dlq_name" {
  type        = string
  description = "Dead letter queue name"
  default     = "securescan-pentest-dlq"
}
