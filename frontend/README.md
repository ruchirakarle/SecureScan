# SecureScan — Harini Hari

## What I Built

### React Frontend (`/frontend`)
Four-page React app deployed to S3 static website hosting.

- **Home** — landing page with project overview
- **Scan** — code paste (SAST) and API URL (Pentest) submission forms
- **Results** — security score (0–100), severity tag, findings breakdown
- **History** — full scan history with CODE/API filter, pulls from `/scans` API

Live URL: `http://securescan-frontend-dev.s3-website-us-east-1.amazonaws.com`

To run locally:

```bash
cd frontend
npm install
npm start
```

To redeploy to S3 after changes:

```bash
npm run build
aws s3 sync build/ s3://securescan-frontend-dev --delete
```

---

### Terraform Infrastructure (`/terraform`)

| File | Resources |
|------|-----------|
| `s3.tf` | Frontend bucket (public website) + Reports bucket (private) |
| `dynamodb.tf` | `securescan-scans-dev` table with 2 GSIs |
| `sns_sqs.tf` | SNS high-severity alerts + DLQ alerts, SQS scan queue + DLQ (3 retries) |
| `variables.tf` | `aws_region`, `project_name`, `environment`, `alert_email` |

To apply:

```bash
cd terraform
terraform init
terraform apply
```

#### DynamoDB Schema

| Key | Type | Notes |
|-----|------|-------|
| `scanId` | String (PK) | UUID per scan |
| `createdAt` | String (SK) | ISO 8601 timestamp |
| `scanType` | String | `CODE` or `API` |
| `severity` | String | `HIGH`, `MEDIUM`, or `LOW` |
| `score` | Number | 0–100 security score |
| `findings` | List | Array of vulnerability objects |
| `target` | String | Code hash or API URL |
| `status` | String | `COMPLETED` or `FAILED` |

GSI 1: `scanType-index` — query by scan type  
GSI 2: `severity-index` — query by severity

---

### Docker Compose (`/docker-compose.yml`)
Runs the full stack locally for development.

```bash
docker-compose up
```

| Service | Port | Notes |
|---------|------|-------|
| `backend` | 3001 | Person 2's Node.js API |
| `pentest` | 3002 | Person 3's pentest container |
| `dynamodb-local` | 8000 | Local DynamoDB (in-memory) |
| `dynamodb-setup` | — | Creates table schema on startup |

---

## API Contract (Frontend expects these from Person 2)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `POST` | `/scan/code` | Body: `{ code: string }` → returns scan result |
| `POST` | `/scan/api` | Body: `{ url: string }` → returns scan result |
| `GET` | `/scans` | Returns array of scan history |

Set the backend URL in `frontend/.env`:




