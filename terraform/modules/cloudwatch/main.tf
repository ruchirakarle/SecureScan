# ── Log Groups ───────────────────────────────────────────

resource "aws_cloudwatch_log_group" "ec2_backend" {
  name              = "/securescan/ec2/backend"
  retention_in_days = 14
  tags = { Name = "securescan-ec2-logs" }
}


# ── EC2 CPU Alarm ─────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "ec2_cpu" {
  alarm_name          = "securescan-ec2-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "EC2 CPU usage exceeded 80%"
  alarm_actions       = [var.sns_topic_arn]
  ok_actions          = [var.sns_topic_arn]
  dimensions = {
    InstanceId = var.ec2_instance_id
  }
}

# ── EC2 Memory Alarm ──────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "ec2_memory" {
  alarm_name          = "securescan-ec2-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "EC2 memory usage exceeded 85%"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    InstanceId = var.ec2_instance_id
  }
}

# ── ECS CPU Alarm ─────────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  alarm_name          = "securescan-ecs-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "ECS Pentest task CPU exceeded 80%"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

# ── ECS Memory Alarm ──────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "ecs_memory" {
  alarm_name          = "securescan-ecs-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 85
  alarm_description   = "ECS Pentest task memory exceeded 85%"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

# ── Lambda Error Alarm ────────────────────────────────────

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  alarm_name          = "securescan-lambda-errors"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 300
  statistic           = "Sum"
  threshold           = 3
  alarm_description   = "Lambda SAST scanner has too many errors"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    FunctionName = "securescan-sast-scanner"
  }
}

# ── Dead Letter Queue Alarm ───────────────────────────────

resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  alarm_name          = "securescan-dlq-not-empty"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Messages in Dead Letter Queue - scan jobs are failing"
  alarm_actions       = [var.sns_topic_arn]
  dimensions = {
    QueueName = var.dlq_name
  }
}
