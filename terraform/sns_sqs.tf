##############################################################
# SNS + SQS — Alerting and retry queues
# Owner: Person 1
##############################################################

# ── SNS: HIGH severity scan alerts ──────────────────────────
resource "aws_sns_topic" "high_severity_alerts" {
  name = "${var.project_name}-high-severity-${var.environment}"

  tags = {
    Name        = "${var.project_name}-high-severity-alerts"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "alert_email" {
  topic_arn = aws_sns_topic.high_severity_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ── SNS: DLQ failure notifications ──────────────────────────
resource "aws_sns_topic" "dlq_alerts" {
  name = "${var.project_name}-dlq-alerts-${var.environment}"

  tags = {
    Name        = "${var.project_name}-dlq-alerts"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "dlq_alert_email" {
  topic_arn = aws_sns_topic.dlq_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

# ── SQS: Dead Letter Queue ───────────────────────────────────
resource "aws_sqs_queue" "scan_dlq" {
  name                      = "${var.project_name}-scan-dlq-${var.environment}"
  message_retention_seconds = 1209600

  tags = {
    Name        = "${var.project_name}-scan-dlq"
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "dlq_alarm" {
  alarm_name          = "${var.project_name}-dlq-not-empty"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  alarm_description   = "Scan job landed in DLQ after 3 retries"
  alarm_actions       = [aws_sns_topic.dlq_alerts.arn]

  dimensions = {
    QueueName = aws_sqs_queue.scan_dlq.name
  }
}

# ── SQS: Main scan queue ─────────────────────────────────────
resource "aws_sqs_queue" "scan_queue" {
  name                       = "${var.project_name}-scan-queue-${var.environment}"
  visibility_timeout_seconds = 30
  message_retention_seconds  = 86400

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.scan_dlq.arn
    maxReceiveCount     = 3
  })

  tags = {
    Name        = "${var.project_name}-scan-queue"
    Environment = var.environment
  }
}

# ── Outputs ──────────────────────────────────────────────────
output "sns_high_severity_arn" {
  value = aws_sns_topic.high_severity_alerts.arn
}

output "sqs_scan_queue_url" {
  value = aws_sqs_queue.scan_queue.url
}

output "sqs_scan_queue_arn" {
  value = aws_sqs_queue.scan_queue.arn
}

output "sqs_dlq_url" {
  value = aws_sqs_queue.scan_dlq.url
}