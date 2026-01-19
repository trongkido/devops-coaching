# Terraform Variables – Complete Guide

## 1. What Are Terraform Variables?

Variables parameterize your Terraform configurations, making them:
- **Flexible** → different environments / regions / sizes without code changes
- **Reusable** → especially in modules
- **Secure** (when used correctly for secrets)

There are four kinds of variables in Terraform:

| Kind              | Purpose                              | Declared with     | Assigned how?                     | Example usage                             |
|-------------------|--------------------------------------|-------------------|------------------------------------|-------------------------------------------|
| **Input variables** | Module / configuration parameters   | `variable` block  | Many ways (tfvars, CLI, env, etc.) | instance_type, region, vpc_cidr           |
| **Local values**    | Internal computed / reused values    | `locals` block    | Only inside the configuration      | common_tags, subnet_cidrs                 |
| **Output values**   | Values returned from a module/root   | `output` block    | Computed from resources/data       | instance_ip, load_balancer_dns            |
| **Module variables**| Input variables inside child modules | `variable` block  | Passed from parent via module block| `module "web" { source = "...", instance_type = var.instance_type }` |

> Most people mean **input variables** when they say "Terraform variables".

## 2. Declaring Input Variables (variables.tf – recommended)

Best practice file naming: `variables.tf` (or split: `networking_variables.tf`, etc.)

```hcl
variable "environment" {
  type        = string
  description = "Deployment environment (dev, staging, prod)"
  default     = "dev"
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 instances to create"
  default     = 2
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "tags" {
  type        = map(string)
  description = "Common resource tags"
  default     = {}
}

variable "db_password" {
  type        = string
  description = "Master password for RDS instance"
  sensitive   = true          # hides value in CLI output & state
  # NO default → must be supplied
}
```

### Supported Types

- `string`
- `number`
- `bool`
- `list(<type>)`    → `list(string)`, `list(number)`
- `set(<type>)`
- `map(<type>)`     → `map(string)`, `map(number)`
- `object({...})`   → strongly typed nested structures
- `any`             → avoid when possible (weak typing)
- `tuple([<types>])` → rarely used

### Validation Blocks (since 0.13+ – very powerful)

```hcl
variable "cidr" {
  type = string
  validation {
    condition     = can(regex("^\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}/\\d{1,2}$", var.cidr))
    error_message = "Must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }
}
```

## 3. 🔐 Sensitive Variables in Terraform

### What Is a Sensitive Variable?
A sensitive variable tells Terraform:

> “⚠️ Do NOT display this value in logs, plans, or outputs.”

Example:
```hcl
variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}
```

Terraform actions:
- Terraform masks the value
- Shows <sensitive> instead of real content

### What Sensitive Variables Actually Protect

✅ Protected

| Location           | Behavior |
| ------------------ | -------- |
| `terraform plan`   | Masked   |
| `terraform apply`  | Masked   |
| `terraform output` | Masked   |
| CLI logs           | Masked   |


❌ NOT Protected

| Location                       | Reality                 |
| ------------------------------ | ----------------------- |
| `terraform.tfstate`            | **Stored in plaintext** |
| Remote backend (S3, GCS, etc.) | **Stored in plaintext** |
| Provider API calls             | Sent in clear text      |
| Memory / runtime               | Visible to Terraform    |

### Using Sensitive Variables Correctly

Variable definition
```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

Usage
```hcl
resource "aws_db_instance" "db" {
  password = var.db_password
}
```

Terraform output:
```hcl
password = <sensitive>
```

### Sensitive Outputs

You must explicitly mark outputs as sensitive. Otherwise Terraform will error.
```hcl
output "db_password" {
  value     = var.db_password
  sensitive = true
}
```

### Sensitive Variables + tfvars (⚠️ Careful)

❌ Bad (Never commit)
```hcl
# terraform.tfvars
db_password = "SuperSecret123!"
```

✅ BEST PRACTICE: Environment Variables
Terraform automatically loads:
```bash
export TF_VAR_db_password="SuperSecret123!"
```

**Advantages:**
- Not written to disk
- Works in CI/CD
- Secure secret injection

### BEST PRACTICE: Secrets Manager (Production)

**AWS Secrets Manager**
```hcl
data "aws_secretsmanager_secret_version" "db" {
  secret_id = "prod/db/password"
}

resource "aws_db_instance" "db" {
  password = data.aws_secretsmanager_secret_version.db.secret_string
}
```

**Benefits:**
- Rotation
- Audit logs
- IAM-controlled access

### Remote Backend Security (VERY IMPORTANT)

Because secrets live in state files, your backend must be secure.

***AWS S3 Backend (Recommended)***
```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-prod"
    key            = "network/terraform.tfstate"
    region         = "ap-southeast-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

✔ Encryption at rest
✔ IAM access control
✔ State locking

### Lifecycle Ignore Changes (Advanced)

If secrets rotate externally:

```hcl
resource "aws_db_instance" "db" {
  password = var.db_password

  lifecycle {
    ignore_changes = [password]
  }
}
```

Prevents forced replacement.

### 🔥 Common Mistakes

❌ Thinking sensitive = true encrypts data
❌ Committing tfvars with secrets
❌ Printing secrets via terraform console
❌ Using output without sensitive = true

### 🧠 Decision Matrix

| Use Case      | Best Solution                |
| ------------- | ---------------------------- |
| Local testing | Sensitive variable + env var |
| CI/CD         | Env vars / secret injection  |
| Production    | Secrets Manager / Vault      |
| Compliance    | Encrypted backend + IAM      |
| Audit         | Avoid outputs entirely       |

## 4. Variable Files – Quick Reference

| File pattern              | Auto-loaded? | Format      | Typical usage                          |
|---------------------------|--------------|-------------|----------------------------------------|
| `terraform.tfvars`        | Yes          | HCL         | Default / common values                |
| `*.auto.tfvars`           | Yes          | HCL         | Environment-specific auto-loading      |
| `*.auto.tfvars.json`      | Yes          | JSON        | CI/CD generated values                 |
| `prod.tfvars`             | No           | HCL         | `terraform apply -var-file=prod.tfvars`|
| Custom `.tfvars`          | No           | HCL         | Explicit loading                       |

### terraform.tfvars

#### What it is
- A special, fixed filename
- Automatically loaded by Terraform
- Only **one** file with this exact name is supported

#### Example
```hcl
project_name   = "devops-lab"
environment    = "dev"
instance_count = 2
```

#### Behavior
- Loaded automatically if present
- No ordering concerns
- Cannot have multiple variants

#### When to use
- Single-environment projects
- Labs and demos
- Local-only testing
- Simple setups

#### Limitations
- Only one file allowed
- Not suitable for multi-environment workflows
- Easy to overwrite by mistake

### *.auto.tfvars

#### What it is
- Any file ending with `.auto.tfvars`
- Terraform automatically loads **all** of them
- Loaded in **alphabetical order**

#### Examples
```text
dev.auto.tfvars
prod.auto.tfvars
region-ap.auto.tfvars
secrets.auto.tfvars
```

#### Load Order (Important)
```text
01-base.auto.tfvars
02-env.auto.tfvars
99-secrets.auto.tfvars
```

Later files override earlier ones.

#### When to use
- Multi-environment infrastructure
- CI/CD pipelines
- Layered configuration
- Team-based Terraform projects

#### Risks
- Harder to debug if naming is unclear
- Overrides can be accidental if not documented

## 5. Variable Assignment – Precedence Order (Highest → Lowest)

This is **the most important table** to understand bugs:

| Priority | Source                                 | Example / Note                                                                 |
|--------|----------------------------------------|---------------------------------------------------------------------------------|
| 1      | CLI `-var` & `-var-file` (left to right) | `terraform apply -var="env=prod" -var-file=prod.tfvars` – highest priority     |
| 2      | HCP Terraform / Terraform Enterprise variables & priority variable sets | Workspace → run → variable sets (priority sets override everything below)      |
| 3      | `*.auto.tfvars` & `*.auto.tfvars.json` | Loaded in lexical (alphabetical) order – `prod.auto.tfvars` overrides `common.auto.tfvars` |
| 4      | `terraform.tfvars.json`                | JSON format                                                                     |
| 5      | `terraform.tfvars`                     | Most common default file – automatically loaded                                 |
| 6      | Environment variables `TF_VAR_<name>`  | `export TF_VAR_region=eu-west-1`                                                |
| 7      | Default value in `variable` block      | Lowest priority                                                                 |

**Tip**: Command-line overrides almost always win → very useful in CI/CD pipelines.

## 6. Real-World Project Structure

```text
terraform/
├── main.tf
├── variables.tf
├── terraform.tfvars        # Local default
├── dev.auto.tfvars         # Dev environment
├── prod.auto.tfvars        # Prod environment
├── secrets.auto.tfvars     # Sensitive values (gitignored)
```

## 7. Best Practices & Pro Tips

1. **Always** add `description` — needed for documentation & terraform-docs
2. **Always** add `type` — prevents type coercion bugs
3. Use `sensitive = true` for secrets (passwords, keys, tokens)
4. Never commit real secrets to `*.tfvars` files in git
5. Prefer `.auto.tfvars` for secrets / per-environment overrides (gitignore them)
6. Use `locals` for computed values instead of many variables

   ```hcl
   locals {
     common_tags = merge(
       var.tags,
       { Environment = var.environment }
     )
   }
   ```

7. Use **plural** names for collections: `subnets`, `azs`, `tags`
8. Use units in names: `disk_size_gb`, `timeout_seconds`
9. Validation > defaults when security/compliance matters
10. One `variables.tf` per logical group in large projects
11. Avoid `any` type unless really necessary
12. Use `object` with `optional()` (Terraform ≥ 1.3) for flexible complex inputs

    ```hcl
    variable "instance_config" {
      type = object({
        type           = string
        count          = number
        monitoring     = optional(bool, false)
        detailed       = optional(bool, true)
      })
    }
    ```

13. **Never** hardcode values in root module that differ per env → make them variables
14. Document complex variables in README.md or with `terraform-docs`
15. In modules: mirror provider/resource argument names when possible

## 8. Common Patterns

**Environment-specific files**

```text
environments/
  dev.tfvars
  staging.tfvars
  prod.tfvars
```

```bash
terraform apply -var-file=environments/prod.tfvars
```

**Sensitive values via environment**

```bash
export TF_VAR_db_password="super-secret-2026"
terraform apply
```

**Dynamic tags**

```hcl
variable "extra_tags" { type = map(string) default = {} }

locals {
  tags = merge(
    {
      ManagedBy   = "Terraform"
      Project     = "WebApp"
      Environment = var.environment
    },
    var.extra_tags
  )
}
```

## 9. Quick Troubleshooting Checklist

- Value not applied? → Check precedence order
- "Variable not used" warning? → You declared but didn't use `var.xxx`
- Sensitive value shown? → Forgot `sensitive = true`
- Type error? → Missing/wrong `type` constraint
- No prompt for value? → You gave a `default = ""` accidentally
