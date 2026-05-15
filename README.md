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
| `security` | Regional WAF on App Runner: rate limit (100 req / 5 min / IP default), IP reputation, optional bot control, logging, auditor IAM |
| `iam_github` | GitHub OIDC provider, OIDC roles, Terraform deployment role (AssumeRole chain), scoped ECR push role |

## GitHub Actions (OIDC)

`modules/iam_github` configures **GitHub OIDC and AssumeRole**. Each environment (**staging** and **production**) creates its **own IAM roles** with different ARNs. After `terraform apply` in each environment folder, read the outputs and configure GitHub accordingly.

### GitHub variables (per environment)

Use **separate values for staging and production**. Do not reuse the same role ARNs across environments.

| GitHub variable (suggested name) | Terraform output | Used for |
|----------------------------------|------------------|----------|
| `GITHUB_ECR_ROLE_ARN` | `github_ecr_oidc_role_arn` | Docker build & push to that env’s ECR repo |
| `GITHUB_TERRAFORM_OIDC_ROLE_ARN` | `github_terraform_oidc_role_arn` | First OIDC login in the Terraform job |
| `TERRAFORM_DEPLOYMENT_ROLE_ARN` | `terraform_deployment_role_arn` | `terraform apply` (AssumeRole target) |

**Where to set them**

- **GitHub Environments** (`staging`, `production`) recommended: each environment has its own variable values so workflows targeting `environment: staging` never get production ARNs.
- Or **repository variables** with names like `STAGING_TERRAFORM_DEPLOYMENT_ROLE_ARN` and `PRODUCTION_TERRAFORM_DEPLOYMENT_ROLE_ARN` if you branch in the workflow with `if:` / matrix.

Example (after apply in `infrastructure/environments/staging`):

```bash
terraform output github_ecr_oidc_role_arn
terraform output github_terraform_oidc_role_arn
terraform output terraform_deployment_role_arn
```

Repeat in `infrastructure/environments/production` — the ARNs will differ (roles are named `challenge-staging-*` vs `challenge-production-*`).

### Role summary

1. **`github_terraform_oidc_role_arn`** — federated trust for repo/branches/environments; may only `sts:AssumeRole` into the deployment role.
2. **`terraform_deployment_role_arn`** — runs `terraform apply` with least-privilege policies scoped to `${project}-${environment}-*` resources and the state bucket prefix.
3. **`github_ecr_oidc_role_arn`** — push images to that environment’s ECR repository only.

Example workflow steps:

```yaml
permissions:
  id-token: write
  contents: read

# Use environment: staging | production so vars.* resolve to the correct ARNs
# ECR push job
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ vars.GITHUB_ECR_ROLE_ARN }}
    aws-region: eu-west-1

# Terraform job (chain to deployment role)
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: ${{ vars.GITHUB_TERRAFORM_OIDC_ROLE_ARN }}
    aws-region: eu-west-1
- run: |
    CREDS=$(aws sts assume-role --role-arn ${{ vars.TERRAFORM_DEPLOYMENT_ROLE_ARN }} --role-session-name terraform)
    export AWS_ACCESS_KEY_ID=...
    terraform apply
```

OIDC trust for each role also includes `repo:ORG/REPO:environment:staging` or `environment:production` (see `github_environments` in `iam_github.tf`), so workflows should set `environment:` in the job to match the target account/roles.

### Application workflow (`application.yml` → `application-reusable.yml`)

Runs on pushes to **`staging`** or **`production`** when files under `application/` change. The caller workflow maps **repository variables** by branch, then invokes the reusable workflow with explicit inputs.

1. **Test and Prettier**: `pnpm test` and `pnpm run format:check`
2. **Deploy**: build/push Docker image to ECR (`latest` + commit SHA tags)
4. **App Runner**: `start-deployment`, wait for success, `GET /health`

Set these as **repository variables** (Settings -> Secrets and variables -> Actions -> Variables):

| Repository variable | Terraform output (staging folder) | Terraform output (production folder) |
|---------------------|-----------------------------------|--------------------------------------|
| `STAGING_GITHUB_ECR_ROLE_ARN` | `github_ecr_oidc_role_arn` | — |
| `STAGING_ECR_REPOSITORY_URL` | `ecr_repository_url` | — |
| `STAGING_APPRUNNER_SERVICE_ARN` | `apprunner_service_arn` | — |
| `STAGING_AWS_REGION` (optional) | `region` | — |
| `PRODUCTION_GITHUB_ECR_ROLE_ARN` | — | `github_ecr_oidc_role_arn` |
| `PRODUCTION_ECR_REPOSITORY_URL` | — | `ecr_repository_url` |
| `PRODUCTION_APPRUNNER_SERVICE_ARN` | — | `apprunner_service_arn` |
| `PRODUCTION_AWS_REGION` (optional) | — | `region` |

Optional fallback for region: `AWS_REGION` (used when `STAGING_AWS_REGION` / `PRODUCTION_AWS_REGION` are unset). Default in the workflow: `eu-west-1`.

The deploy job still sets `environment: staging` or `production` for GitHub Environment protection rules and OIDC `environment:` claims.

After updating IAM (App Runner deploy permissions on the ECR OIDC role), run `terraform apply` in that environment.

### Infrastructure workflow (`infrastructure.yml` → `infra-deploy.yml`)

Runs on pushes to **`staging`** or **`production`** when files under `infrastructure/` change:

1. **Terraform validate**: `terraform fmt -check`, `init -backend=false`, `validate`
2. **Terraform plan**: OIDC deployment role chain, `plan`, upload plan artifact
3. **Terraform apply**: Requires **manual approval** (GitHub Environment), then `apply` the saved plan

#### Manual approval before apply

GitHub does not approve individual steps; it gates **jobs** via [Environment protection rules](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment#deployment-protection-rules).

1. In the repo: **Settings -> Environments** -> open `staging` and/or `production` (same names the workflow uses).
2. Enable **Required reviewers** and add people/teams who may approve applies.
3. Optional: **Wait timer**, **Deployment branches** (limit to `staging` / `production`).

After **plan** finishes, the **apply** job shows *Review pending deployment* until a reviewer approves. Reviewers can read the `plan.txt` artifact from the plan job before approving.

Use stricter rules on `production` (required reviewers) and none on `staging` if you want staging to apply automatically.

**Repository variables** (from `terraform output` in each environment folder):

| Repository variable | Terraform output |
|---------------------|------------------|
| `STAGING_GITHUB_TERRAFORM_OIDC_ROLE_ARN` | `github_terraform_oidc_role_arn` |
| `STAGING_TERRAFORM_DEPLOYMENT_ROLE_ARN` | `terraform_deployment_role_arn` |
| `PRODUCTION_GITHUB_TERRAFORM_OIDC_ROLE_ARN` | `github_terraform_oidc_role_arn` |
| `PRODUCTION_TERRAFORM_DEPLOYMENT_ROLE_ARN` | `terraform_deployment_role_arn` |

Optional: `STAGING_AWS_REGION`, `PRODUCTION_AWS_REGION`, or shared `AWS_REGION`.

**Repository secrets** (full contents of your local `terraform.tfvars`, which is gitignored):

| Secret | Used when branch is |
|--------|---------------------|
| `STAGING_TERRAFORM_TFVARS` | `staging` |
| `PRODUCTION_TERRAFORM_TFVARS` | `production` |

Example secret value (staging):

```hcl
role_arn               = "arn:aws:iam::ACCOUNT_ID:role/YourTerraformRole"
env_secret_manager_arn = "arn:aws:secretsmanager:eu-west-1:ACCOUNT_ID:secret:..."
github_repository      = "org/challenge_infrastructure"
```

### Pre-commit

```bash
pip install pre-commit   # or: brew install pre-commit
pre-commit install
```

Hooks: Terraform `validate` (staging + production when `infrastructure/` changes), application Prettier check, and Jest tests.

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
