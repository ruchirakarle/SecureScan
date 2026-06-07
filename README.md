# SecureScan
### Paste. Scan. Secure.

CS6620 Cloud Computing — Summer 2026 — Northeastern University  
Group 10 — Ruchira Ravindra Karle, Isha Pargaonkar, Harini Hari

---

## What is this?

SecureScan is a cloud-native security tool we built for our CS6620 final project. The idea came from a simple problem — if you want to quickly check your code or an API for security issues, your options are either expensive enterprise tools or doing it manually. We wanted something where you just paste your code or drop in a URL and get results back in seconds, no setup required.

There are two things it can do:

**Code Scan (SAST)** — paste JavaScript code and it checks for 10 different vulnerability types and gives you a score out of 100 with a breakdown by severity.

**API Scan (Pentest)** — enter a live API URL and it runs 6 security checks against it and tells you what passed and what didn't.

Everything runs on AWS and all scan history gets saved so you can go back and look at previous results.

---

## How it works

The architecture is split into 4 layers:

**Frontend** — React app hosted on S3 as a static website. This is what the user actually sees — the scan submission page, results page, and history dashboard.

**API Layer** — API Gateway sits in front of everything as the public HTTPS endpoint. The Node.js backend runs on EC2 and handles incoming scan requests, writes jobs to SQS queues, and serves results from DynamoDB.

**Compute** — Two separate scanner microservices:
- SAST scanner runs as a Lambda function — reads from the SAST SQS queue, runs the code scan, writes results to S3 and DynamoDB
- Pentest scanner runs as a Dockerized ECS Fargate task — reads from the Pentest SQS queue, runs the 6 API checks, writes results to S3 and DynamoDB

**Storage and Alerts** — DynamoDB stores scan metadata and history. S3 stores the full JSON scan reports. SNS sends an email alert any time a HIGH severity finding is detected.

---

## AWS Services Used

| Service | What we use it for |
|---|---|
| EC2 | Runs the Node.js backend API |
| S3 | Hosts the React frontend + stores scan reports |
| DynamoDB | Stores scan history and metadata |
| Lambda | Runs the SAST scanner |
| ECS Fargate | Runs the Pentest scanner |
| SQS | Job queues for both scanners + dead letter queues |
| SNS | Email alerts for HIGH severity findings |
| API Gateway | Public HTTPS endpoint |
| CloudWatch | Logs and monitoring for all services |
| ECR | Stores the Pentest Docker image |
| VPC | Network isolation — public/private subnets |

---

## Project Structure

```
SecureScan/
├── frontend/               # React frontend (Person 1)
├── terraform/              # All infrastructure as code
│   ├── vpc.tf              # VPC, subnets, NAT gateway (Person 3)
│   ├── s3.tf               # S3 buckets (Person 1)
│   ├── dynamodb.tf         # DynamoDB table (Person 1)
│   ├── sns_sqs.tf          # SNS topics + SQS queues (Person 1)
│   ├── ec2.tf              # EC2 + security groups (Person 2)
│   ├── lambda.tf           # SAST Lambda function (Person 2)
│   └── ecs.tf              # ECS cluster + Fargate task (Person 3)
├── backend/                # Node.js API on EC2 (Person 2)
├── sast-scanner/           # SAST Lambda function (Person 2)
└── pentest-service/        # Pentest Fargate container (Person 3)
    ├── scanner.js
    ├── package.json
    └── Dockerfile
```

---

## Team and Work Split

**Person 1 — Isha Pargaonkar — Frontend + Infrastructure Core**
- React frontend (home, scan submission, results, history pages)
- S3 static website deployment
- Terraform for S3, DynamoDB, SNS, SQS + dead letter queues
- Local docker-compose for team development

**Person 2 — Harini Hari — Backend API + SAST Microservice**
- Node.js/Express API on EC2
- SAST scanner as Lambda function
- SQS retry logic (3 retries) + DLQ + SNS failure alerts
- Terraform for EC2, Lambda, IAM roles, security groups

**Person 3 — Ruchira Ravindra Karle — Pentest Microservice + VPC + Monitoring**
- Pentest scanner as Dockerized ECS Fargate task
- SQS retry logic (3 retries) + DLQ + SNS failure alerts
- VPC design (public/private subnets, NAT gateway, VPC endpoints)
- CloudWatch alarms for CPU, memory, Lambda errors
- Terraform for VPC, ECS cluster, ECR repository

---

## What the Pentest Scanner checks

When you submit an API URL it runs these 6 checks:

1. HTTPS Enforcement — is the endpoint using HTTPS?
2. Security Headers — does the response include X-Frame-Options, X-Content-Type-Options, HSTS?
3. SQL Injection Probe — checks for obvious SQLi vectors
4. XSS Probe — checks for reflected XSS
5. Open Redirect Check — checks for open redirect vulnerabilities
6. Sensitive Data Exposure — checks if sensitive terms appear in the URL

Each check is pass/fail with a severity (LOW/MEDIUM/HIGH) and the overall score is calculated as (passed / total) * 100.

---

## DynamoDB Schema

Each scan (both SAST and Pentest) gets stored with this structure:

```

```

---

## Success Criteria

- Users can paste code and run a SAST scan from the web UI
- Users can enter an API URL and run a Pentest scan from the web UI
- Every scan gets a 0-100 security score
- All results are saved and viewable in the history page
- HIGH severity findings trigger an SNS email alert automatically
- Platform is deployed on AWS with a public URL
- Scan response time under 5 seconds for SAST
- All 6 pentest checks run per API scan
- 100% of scans persisted to DynamoDB

---

## How to run locally





