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

## 3. Variable Assignment – Precedence Order (Highest → Lowest)

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

**Tip 2026**: Command-line overrides almost always win → very useful in CI/CD pipelines.

## 4. Variable Files – Quick Reference

| File pattern              | Auto-loaded? | Format      | Typical usage                          |
|---------------------------|--------------|-------------|----------------------------------------|
| `terraform.tfvars`        | Yes          | HCL         | Default / common values                |
| `*.auto.tfvars`           | Yes          | HCL         | Environment-specific auto-loading      |
| `*.auto.tfvars.json`      | Yes          | JSON        | CI/CD generated values                 |
| `prod.tfvars`             | No           | HCL         | `terraform apply -var-file=prod.tfvars`|
| Custom `.tfvars`          | No           | HCL         | Explicit loading                       |

## 5. Best Practices & Pro Tips

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

## 6. Common Patterns

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

## 7. Quick Troubleshooting Checklist

- Value not applied? → Check precedence order
- "Variable not used" warning? → You declared but didn't use `var.xxx`
- Sensitive value shown? → Forgot `sensitive = true`
- Type error? → Missing/wrong `type` constraint
- No prompt for value? → You gave a `default = ""` accidentally
