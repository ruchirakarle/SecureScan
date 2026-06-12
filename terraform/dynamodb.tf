##############################################################
# DynamoDB — Scan history table
# Owner: Person 1
#
# Schema:
#   PK:  scanId     (String) — UUID per scan (no range key)
#
# GSI 1: scanType-index
#   PK:  scanType   (String) — "CODE" | "API" — for history per type
#
# GSI 2: severity-index
#   PK:  severity   (String) — "HIGH" | "MEDIUM" | "LOW" — for filtering by severity
##############################################################

resource "aws_dynamodb_table" "scans" {
  name         = "${var.project_name}-scans-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "scanId"

  attribute {
    name = "scanId"
    type = "S"
  }

  attribute {
    name = "scanType"
    type = "S"
  }

  attribute {
    name = "severity"
    type = "S"
  }

  global_secondary_index {
    name            = "scanType-index"
    hash_key        = "scanType"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "severity-index"
    hash_key        = "severity"
    projection_type = "ALL"
  }

  tags = {
    Name        = "${var.project_name}-scans"
    Environment = var.environment
  }
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.scans.name
}

output "dynamodb_table_arn" {
  value = aws_dynamodb_table.scans.arn
}