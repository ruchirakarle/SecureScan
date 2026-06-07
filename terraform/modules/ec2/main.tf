resource "aws_security_group" "backend" {
  name        = "securescan-backend-sg"
  description = "Security group for SecureScan backend API"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "securescan-backend-sg" }
}

resource "aws_instance" "backend" {
  ami                    = var.ami_id
  instance_type          = "t2.micro"
  subnet_id              = var.public_subnet_id
  vpc_security_group_ids = [aws_security_group.backend.id]
  iam_instance_profile   = aws_iam_instance_profile.backend.name
  key_name               = var.key_pair_name

  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    aws_region         = var.aws_region
    dynamodb_table     = var.dynamodb_table
    s3_bucket          = var.s3_reports_bucket
    sqs_sast_queue_url = var.sqs_sast_queue_url
    sqs_pentest_url    = var.sqs_pentest_queue_url
    sns_topic_arn      = var.sns_topic_arn
    sast_scanner_url   = var.sast_scanner_url
  }))

  tags = { Name = "securescan-backend" }
}

resource "aws_iam_role" "backend" {
  name = "securescan-backend-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy" "backend" {
  name = "securescan-backend-policy"
  role = aws_iam_role.backend.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem", "dynamodb:GetItem",
          "dynamodb:UpdateItem", "dynamodb:Scan", "dynamodb:Query"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/${var.dynamodb_table}*"
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:ListBucket"]
        Resource = ["arn:aws:s3:::${var.s3_reports_bucket}/*",
                    "arn:aws:s3:::${var.s3_reports_bucket}"]
      },
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage", "sqs:GetQueueAttributes"]
        Resource = "*"
      },
      {
        Effect   = "Allow"
        Action   = ["sns:Publish"]
        Resource = var.sns_topic_arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "backend" {
  name = "securescan-backend-profile"
  role = aws_iam_role.backend.name
}