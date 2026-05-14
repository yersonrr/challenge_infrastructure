# challenge_infrastructure

Challenge created for a Senior Cloud Infrastructure Engineer role.

## Scope

The challenge treats **infrastructure as code** with a clear split between **reusable modules** and **work environments** under `infrastructure/modules` and `infrastructure/environments` (for example staging and production). Terraform composes shared building blocks from `modules` into each environment’s configuration.

At the **repository root**, the **application** lives alongside `infrastructure/`. It is where **authentication** and **business logic** are implemented. Keeping app and infrastructure in one repository helps align releases, configuration, and IAM expectations.

## Before deploying Terraform

To start working with this infrastructure you need:

1. **An IAM role** that Terraform can assume for the target account (see the `role_arn` variable in the environment configuration, where applicable). Grant this principal the permissions required for your resources and for **S3 state access** (including lock objects when `use_lockfile` is enabled).
2. **An S3 bucket** for remote Terraform state. Create the bucket, then align `backend.hcl` (from `backend.hcl.example`) with your bucket name and region, and run `terraform init -backend-config=backend.hcl` in the chosen environment directory.

   For the state bucket, at minimum:

   - **Block all public access** (S3 Block Public Access settings so the bucket and objects are not exposed publicly).
   - **Turn on bucket versioning** so you can recover from accidental overwrites or mistaken deletes of the state object.
   - **Server-side encryption** for objects in the bucket is also recommended.

Variable files (`*.tfvars`) are ignored by git; keep secrets and account-specific values out of version control.
