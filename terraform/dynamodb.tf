##############################################################
# DynamoDB — Scan history table
# Owner: Person 1
#
# Schema:
#   PK:  scanId     (String) — UUID per scan
#   SK:  createdAt  (String) — ISO 8601 timestamp
#
# GSI 1: scanType-createdAt-index
#   PK:  scanType   (String) — "CODE" | "API"
#   SK:  createdAt  (String) — for sorted history per type
#
# GSI 2: severity-createdAt-index
#   PK:  severity   (String) — "HIGH" | "MEDIUM" | "LOW"
#   SK:  createdAt  (String) — for filtering by severity
##############################################################

resource "aws_dynamodb_table" "scans" {
  name         = "${var.project_name}-scans-${var.environment}"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "scanId"
  range_key    = "createdAt"

  attribute {
    name = "scanId"
    type = "S"
  }

  attribute {
    name = "createdAt"
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
    name            = "scanType-createdAt-index"
    hash_key        = "scanType"
    range_key       = "createdAt"
    projection_type = "ALL"
  }

  global_secondary_index {
    name            = "severity-createdAt-index"
    hash_key        = "severity"
    range_key       = "createdAt"
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