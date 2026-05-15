# challenge_infrastructure

Challenge created for a Senior Cloud Infrastructure Engineer role.

## Scope

The challenge treats **infrastructure as code** with a clear split between **reusable modules** and **work environments** under `infrastructure/modules` and `infrastructure/environments` (for example staging and production). Terraform composes shared building blocks from `modules` into each environment’s configuration.

At the **repository root**, the **application** lives alongside `infrastructure/`. It is where **authentication** and **business logic** are implemented. Keeping app and infrastructure in one repository helps align releases, configuration, and IAM expectations.

## Why DynamoDB?

The **`modules/db`** stack uses **Amazon DynamoDB** for the URL shortener and user-authentication data.

**Redirects must stay fast.** Resolving a short link is a single-key lookup (`shortCode` then `longUrl`). DynamoDB is built for that pattern: predictable, low latency reads at scale without connection pooling or query planning overhead. That fits a public redirect endpoint where every extra millisecond matters.

**Operational simplicity for the challenge.** On-demand billing (`PAY_PER_REQUEST`), no VPC database subnets, and no RDS maintenance make it easier to focus on Terraform, App Runner, and the NestJS app. Passwords are stored as hashes in the app (`passwordHash` on each user item); DynamoDB only persists the result.

### Future work (PostgreSQL)

DynamoDB is a deliberate starting point, not a permanent solution. **PostgreSQL** should be used(for example RDS or Aurora) if requirements grow:

| Area | Stay on DynamoDB | Consider PostgreSQL |
|------|------------------|---------------------|
| **URL redirects** | High-volume, simple key lookups | Not the best approach if we want to read the table and stay consistent for Millions of URLs. |
| **Users & auth** | Fine for the initial sign-up/login setup | Better fit for complex roles, audits, migrations, and SQL queries across users and sessions. |
| **URLs (for management)** | Owner listing via GSI works for moderate scale | Better for admin dashboards, analytics joins (user, link, click), and constraints across tables |

## Before deploying Terraform

To start working with this infrastructure you need:

1. **An IAM role** that Terraform can assume for the target account (see the `role_arn` variable in the environment configuration, where applicable). Grant this principal the permissions required for your resources and for **S3 state access** (including lock objects when `use_lockfile` is enabled).
2. **An S3 bucket** for remote Terraform state. Create the bucket, then align `backend.hcl` (from `backend.hcl.example`) with your bucket name and region, and run `terraform init -backend-config=backend.hcl` in the chosen environment directory.

   For the state bucket, at minimum:

   - **Block all public access** (S3 Block Public Access settings so the bucket and objects are not exposed publicly).
   - **Turn on bucket versioning** so you can recover from accidental overwrites or mistaken deletes of the state object.
   - **Server-side encryption** for objects in the bucket is also recommended.

Variable files (`*.tfvars`) are ignored by git; keep `env_secret_manager_arn` and secret payloads out of version control.

## Modules overview

| Module | Purpose |
|--------|---------|
| `network` | VPC, public/private subnets, security groups for App Runner VPC connector |
| `db` | DynamoDB tables for URLs and users (GSI keys use `key_schema`, not deprecated `hash_key` / `range_key`) |
| `ecr` | Container registry, scan-on-push, lifecycle (keep 10 images), optional CI IAM policy |
| `apprunner` | Public NestJS service, ECR image, auto scaling, VPC connector, IAM, Secrets Manager config |

## Application configuration (Secrets Manager)

Create a **JSON secret in AWS Secrets Manager before** deploying App Runner. Terraform does **not** create the secret. Pass its ARN as `env_secret_manager_arn` in `terraform.tfvars`.

Example secret value:

```json
{
  "JWT_SECRET": "your-long-random-string",
  "DB_ENDPOINT": "https://dynamodb.eu-west-1.amazonaws.com",
  "URLS_TABLE_NAME": "challenge-staging-urls",
  "USERS_TABLE_NAME": "challenge-staging-users",
  "NODE_ENV": "production"
}
```

`modules/apprunner` maps keys via `runtime_environment_secrets` only—**no plain environment variables**. Restrict secret access with IAM so only App Runner (and approved operators) can read it.

**Deploy order:**
- Create/Modify secret
- Push image to ECR
- Apply Terraform with `env_secret_manager_arn`. 
- Health check: `GET /health` on port `3000`.
