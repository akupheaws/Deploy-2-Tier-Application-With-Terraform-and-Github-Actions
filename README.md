# Deploy a 2‑Tier Application with Terraform & GitHub Actions

A clean, portfolio‑ready project that deploys a classic **two‑tier web application** (web/app tier + data tier) on AWS using **Terraform** and **GitHub Actions** for CI/CD. The repo also includes a small Node.js app (`index.js`) with static assets (`public/`) to demonstrate end‑to‑end delivery.

> Tech mix (by lines of code in this repo): **Terraform (HCL)**, **JavaScript (Node/Express)**, **CSS/HTML**, and some **shell** utilities.

---

## ✨ What this project demonstrates

- **Two‑tier architecture** on AWS with Terraform (networking + compute + data).
- **Push‑to‑deploy** via GitHub Actions (plan/apply, lint/tests, environment promotion).
- **Parameterizable environments** (e.g., `dev`, `prod`) driven by variables and GitHub secrets.
- **Zero local credentials in code** — CI uses ephemeral credentials or OIDC to assume IAM roles.

---

## 🏗️ Architecture (high level)

```
             ┌───────────────────────────── GitHub Actions ─────────────────────────────┐
             │  on: push / pull_request                                                 │
             │  • terraform fmt/validate  • plan  • apply (main)  • tests               │
             └──────────────────────────────────────────────────────────────────────────┘

┌────────────────────────────── AWS ──────────────────────────────┐
│  VPC (2 AZs)                                                     │
│  ┌───────────────┐      ┌──────────────────┐                     │
│  │ Public Subnet │◄────►│  Internet GW     │                     │
│  └─────┬─────────┘      └──────────────────┘                     │
│        │                                                      ┌──▼───────────┐
│   ALB / SG                                                   │  App Tier    │
│        │  routes to target group                             │  (EC2 or     │
│  ┌─────▼─────────┐                                          │  ECS Fargate)│
│  │ Node.js App   │  serves API & static `public/`           └──┬───────────┘
│  │ (index.js)    │                                              │
│  └───────────────┘                                              │
│                                                                 │
│                                                ┌────────────────▼──────────┐
│                                                │  Data Tier (e.g., RDS)    │
│                                                │  private subnets + SG      │
│                                                └────────────────────────────┘
└─────────────────────────────────────────────────────────────────────────────┘
```

> The exact service choices (EC2 vs ECS Fargate, RDS engine, etc.) are configurable via Terraform variables.

---

## 📦 Repository layout

```
.
├─ .github/workflows/    # CI/CD pipelines (Terraform plan/apply, tests, lint)
├─ terraform/            # Reusable IaC for VPC, security groups, compute, RDS, etc.
├─ scripts/              # Helper scripts (bootstrap/user-data, test, util)
├─ public/               # Static assets served by the app
├─ index.js              # Minimal Node/Express server
├─ package.json          # App scripts and dependencies
└─ package-lock.json
```

---

## 🔧 Prerequisites

- **AWS account** with permissions to create VPC, EC2/ECS, ALB, RDS, IAM, etc.
- **Terraform ≥ 1.5** (local use) — CI runs Terraform for you.
- **Node.js ≥ 18** if you want to run the sample app locally.
- **GitHub Actions** with either **OIDC → AWS IAM role** _or_ stored AWS keys (recommended: OIDC).

---

## 🗝️ Required secrets & variables (GitHub Actions)

Set these in **Settings → Secrets and variables → Actions**:

- `AWS_ACCOUNT_ID` – your AWS account number (if using OIDC role assumption).
- `AWS_ROLE_TO_ASSUME` – IAM role ARN that CI should assume (OIDC).
- `AWS_REGION` – e.g., `us-east-1`.
- (_If not using OIDC_) `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, and optionally `AWS_SESSION_TOKEN`.
- Optional app/db settings used by Terraform or user data:
  - `APP_NAME`, `ENVIRONMENT` (`dev`/`prod`), `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD` (use **secrets**, never commit).

> If your workflows are split into `plan.yml` and `apply.yml`, mirror the same secret names in both. If you use a single workflow, keep them centralized.

---

## 🚀 How to deploy (CI/CD)

1. **Fork or push** to the repository.
2. Update `terraform/variables.tf` (or your env files) with desired CIDR blocks, instance sizes, DB engine/version, etc.
3. Push a branch → open a PR → **CI runs Plan**. Review the plan output in the Actions logs.
4. Merge to `master`/`main` → **CI runs Apply** and outputs the ALB DNS name or public URL as a Terraform output.
5. Visit the URL to verify the Node app is live.

> Want manual approvals? Add an **environment** in GitHub with required reviewers on the apply job.

---

## 🧪 Local development (optional)

```bash
# 1) Install app dependencies
npm install

# 2) Start the sample server
npm start
# Default: http://localhost:3000

# 3) Lint / tests (add as needed)
npm run lint
npm test
```

You can also run Terraform locally if preferred:

```bash
cd terraform
terraform init
terraform plan -var="environment=dev"
terraform apply -auto-approve -var="environment=dev"
```

> Use a dedicated AWS profile or temporary credentials. Never commit state files; use an S3/DynamoDB backend for real deployments.

---

## ⚙️ Notable Terraform components

- **Networking:** VPC, public/private subnets across 2 AZs, route tables, NAT/IGW.
- **Security:** Security groups with least‑privilege ingress/egress; parameterized CIDRs.
- **Compute:** App tier on EC2 ASG or ECS Fargate with ALB target group and health checks.
- **Data:** Managed database (RDS) in private subnets; credentials via variables/SSM/Secrets Manager.
- **Outputs:** ALB DNS, DB endpoint/port, and any bootstrap URLs.

> Check `terraform/` for exact resources and configurable variables.

---

## 🤖 CI/CD pipeline (example overview)

Typical stages you’ll see in `.github/workflows/`:

1. **Checkout + Setup Terraform/Node**  
2. **Lint/Validate** (`terraform fmt -check`, `terraform validate`, `npm run lint`)  
3. **Plan** on PR branches with artifacts uploaded  
4. **Apply** on `main` with manual approval (optional)  
5. **Post‑deploy smoke test** (curl the ALB DNS; check `200 OK`)  
6. **Destroy** workflow (on demand) for ephemeral environments

Add a status badge once you know your workflow filename, e.g.:

```md
[![CI](https://github.com/<owner>/<repo>/actions/workflows/ci.yml/badge.svg)](https://github.com/<owner>/<repo>/actions)
```

---

## 🔒 Security & cost notes

- Prefer **OIDC** with a trust policy that limits repo, branch, and conditions. Rotate secrets if keys are used.
- Scope IAM policies to the minimum resources needed.
- Tag all resources (`Project`, `Env`, `Owner`) and consider budgets/alerts.
- Clean up with `terraform destroy` or a scheduled cleanup job for non‑prod.

---

## 🧭 Troubleshooting

- **Plan says “no changes” but app isn’t reachable** → check ALB target health and security groups.
- **Apply fails assuming role** → verify OIDC provider, role trust policy, and repository/branch conditions.
- **DB connection errors** → confirm SG rules (app → DB), username/password, and subnet group placement.

---

## 🛣️ Roadmap

- [ ] Add OpenAPI/Swagger UI for the sample API
- [ ] Add Dockerfile and `docker-compose.yml` for local parity
- [ ] Blue/Green or Rolling deploys via weighted target groups
- [ ] Add synthetic monitoring in CI (k6/Playwright) after deploy
- [ ] Multi‑region DR (Route 53 failover/health checks)

---

## 📜 License

MIT © Akuphe
