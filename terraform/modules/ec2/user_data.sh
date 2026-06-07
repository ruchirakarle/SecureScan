#!/bin/bash
set -e

# Install Docker
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
  -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create app directory
mkdir -p /app

# Write environment file
cat > /app/.env << EOF
PORT=3001
AWS_REGION=${aws_region}
DYNAMODB_TABLE=${dynamodb_table}
S3_REPORTS_BUCKET=${s3_bucket}
SQS_SAST_QUEUE_URL=${sqs_sast_queue_url}
SQS_PENTEST_QUEUE_URL=${sqs_pentest_url}
SNS_TOPIC_ARN=${sns_topic_arn}
SAST_SCANNER_URL=${sast_scanner_url}
EOF

echo "EC2 setup complete. Deploy your Docker image to start the backend."