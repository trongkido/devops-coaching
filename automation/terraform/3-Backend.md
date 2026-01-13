# Terraform Backend - Complete Guide & Best Practices

The **Terraform backend** defines **where** and **how** Terraform stores its **state file** (`terraform.tfstate`).

Choosing and configuring the right backend is one of the **most important decisions** in any serious Terraform project.

## 1. What is a Terraform Backend?

- The **state file** contains:
  - Mapping between resources in code ↔ real resources in cloud
  - Last known attributes of every resource
  - Outputs values
  - Resource dependencies graph

- Without a proper **remote backend**, state lives only on your local disk → **very dangerous** in team environments

## 2. Local vs Remote Backend Comparison

| Feature                        | local (default)          | Remote (recommended)          |
|--------------------------------|---------------------------|-------------------------------|
| Team collaboration             | ✗ Impossible             | ✓ Yes                         |
| State locking                  | ✗ No                     | ✓ Yes (prevents conflicts)    |
| State encryption at rest       | ✗ No                     | ✓ Usually yes                 |
| Disaster recovery              | Manual backup            | Usually built-in              |
| CI/CD safety                   | Very dangerous           | Safe                          |
| Versioning of state            | Manual                   | Usually automatic             |

**Golden Rule 2025–2026**:  
**Never** use the `local` backend in any project that has more than 1 person or runs in CI/CD.

## 3. Most Popular & Recommended Backends (2025–2026)

| Rank | Backend              | Locking | Encryption | Versioning | Best For                              | Difficulty |
|------|----------------------|---------|------------|------------|---------------------------------------|------------|
| 1    | s3 + dynamodb        | Yes     | Yes (KMS)  | Yes        | AWS teams, most production use-cases  | ★★☆        |
| 2    | azurerm (Blob + Lock)| Yes     | Yes        | Yes        | Azure-first organizations             | ★★☆        |
| 3    | gcs                  | Yes     | Yes        | Yes        | Google Cloud projects                 | ★★         |
| 4    | terraform cloud      | Yes     | Yes        | Yes + UI   | Teams wanting managed experience      | ★☆         |
| 5    | pg (PostgreSQL)      | Yes     | Depends    | Manual     | Self-hosted, strong governance        | ★★★        |
| 6    | consul               | Yes     | Yes        | No         | HashiCorp heavy stack                 | ★★★        |
| 7    | http                 | Partial | Depends    | Depends    | Very custom / legacy integrations     | ★★★★       |

## 4. Recommended Production Configuration Examples

### AWS – S3 + DynamoDB (still #1 choice in 2026)

```hcl
terraform {
  backend "s3" {
    bucket         = "mycompany-terraform-state-2026"
    key            = "prod/networking/terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    kms_key_id     = "alias/terraform-state-key"   # optional but strongly recommended

    # Very important for large states
    skip_region_validation      = false
    skip_credentials_validation = false
    skip_requesting_account_id  = false   # needed for cross-account assume-role
  }
}
```
Best practices for S3 backend:
- Use unique bucket per organization (or per business unit)
- Enable bucket versioning
- Use KMS encryption (customer-managed key)
- Use DynamoDB for locking (partition key = LockID)
- Use path-style keys: environment/component/terraform.tfstate

Terraform Cloud / Enterprise (managed & easiest for teams)
```hcl
terraform {
  backend "remote" {
    hostname     = "app.terraform.io"          # or your private TFC/Enterprise host
    organization = "my-company"

    workspaces {
      name = "prod-networking"                 # or use prefix / tags strategy
    }
  }
}
```

## 5. Important Backend Best Practices
1. Never commit secrets to backend block
→ Use partial configuration + -backend-config file / env variables
```hcl
terraform init \
  -backend-config="bucket=mycompany-terraform-state" \
  -backend-config="key=prod/app/terraform.tfstate" \
  -backend-config="dynamodb_table=terraform-lock"
```

2. Use workspace key strategy (very popular pattern)
```hcl
key = "${terraform.workspace}/terraform.tfstate"
```

3. Separate state per environment & component
Good structure:
```text
prod/
  networking/
  database/
  apps/
staging/
  networking/
  ...
```

4. Always enable encryption
- Especially important when state contains secrets (DB passwords, keys…)

5. State locking is mandatory
- Prevents concurrent terraform apply → corrupted state

6. Keep state files reasonably sized
- < 1MB: comfortable
- 5–10MB: acceptable
-  20MB: you should split into multiple states / use data sources

7. Use remote state data source carefully
```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "mycompany-terraform-state-2026"
    key    = "prod/networking/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
```
