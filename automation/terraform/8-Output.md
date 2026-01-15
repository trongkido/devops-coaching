# Terraform Outputs – Complete Guide

## 1. What Are Terraform Outputs?

Output values expose selected data from your Terraform configuration after `apply`.  
They serve four main purposes:

- Display important information in CLI after `terraform apply`
- Allow parent modules to consume child module results
- Enable remote state access via `terraform_remote_state` data source (or HCP Terraform workspace state sharing)
- Pass values to external automation / CI/CD / scripts

```hcl
output "instance_public_ip" {
  value = aws_instance.web.public_ip
}
```

After `apply`:

```bash
$ terraform apply
...
Outputs:

instance_public_ip = "3.124.89.177"
```

## 2. Output Block Syntax (outputs.tf – recommended)

Best practice: put all outputs in `outputs.tf` (or split like `network_outputs.tf`)

```hcl
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id

  # Optional arguments
  sensitive   = false     # default
  depends_on  = [aws_internet_gateway.main]
  precondition {
    condition     = length(aws_vpc.main.id) > 0
    error_message = "VPC ID must not be empty after creation."
  }
}
```

### All Supported Arguments (Terraform ≥ 1.0+)

| Argument     | Type      | Required? | Purpose                                                                 | Since     |
|--------------|-----------|-----------|-------------------------------------------------------------------------|-----------|
| `value`      | any       | **Yes**   | The actual value to expose (resource attr, computed local, etc.)       | always    |
| `description`| string    | No        | Human-readable explanation — shown in `terraform output -json`         | 0.12+     |
| `sensitive`  | bool      | No        | Redact value in CLI (`<sensitive>`), still stored in state             | 0.15+     |
| `depends_on` | list      | No        | Explicit dependency (rarely needed — Terraform infers most deps)       | 1.3+      |
| `precondition` block | — | No | Validate output value before exposing / storing in state              | 1.2+      |

## 3. Sensitive Outputs – Most Important Topic

Terraform aggressively marks values **sensitive** when:

- Input variable has `sensitive = true`
- Resource attribute is known to be sensitive (password, secret, token…)
- Any part of a complex value (map/list/object) is sensitive → whole value becomes sensitive

Behavior:

| Command                          | Sensitive Output Shown?          | Plaintext?                  |
|----------------------------------|----------------------------------|-----------------------------|
| `terraform apply` / `plan`       | `<sensitive>`                    | No                          |
| `terraform output`               | `<sensitive>`                    | No                          |
| `terraform output -json`         | actual value                     | **Yes** (dangerous!)        |
| `terraform output -raw`          | actual value                     | **Yes**                     |
| Remote state (`terraform_remote_state`) | actual value              | **Yes** (state is plaintext)|

### How to Safely Handle Secrets

1. **Mark outputs sensitive** when they contain secrets

```hcl
output "db_password" {
  value     = aws_db_instance.main.password
  sensitive = true
}
```

2. **Never rely on sensitive = false** to force display — Terraform may override it if value contains sensitive data

3. **Debugging tip** — temporarily reveal value (use with care!):

```hcl
# Only for debugging – commit with sensitive = true
output "db_password_debug" {
  value = nonsensitive(aws_db_instance.main.password)
}
```

4. Use `nonsensitive()` sparingly (Terraform ≥ 0.15)

```hcl
output "safe_hash" {
  value = nonsensitive(sha256(var.secret_token))
}
```

→ Only safe if result is **not** reversible / secret-leaking

**2026 Rule of Thumb**  
If someone can copy-paste your `terraform output -json` and gain access → it should be `sensitive = true`

## 4. Accessing Outputs

| Context                     | How to access                                      | Example                                  |
|-----------------------------|----------------------------------------------------|------------------------------------------|
| CLI (root module)           | `terraform output` / `terraform output vpc_id`     | `3.8.1.44`                               |
| JSON machine-readable       | `terraform output -json`                           | CI/CD parsing                            |
| Child → Parent module       | `module.web.public_ip`                             | Inside root module                       |
| Remote state                | `data "terraform_remote_state" "network" { … }`    | `data.terraform_remote_state.network.outputs.vpc_id` |
| HCP Terraform / TFE         | Workspace → Outputs tab or API                     | Automations / other workspaces           |

## 5. Best Practices & Pro Tips

1. **Always** add `description` — required by `terraform-docs`, modules registry, good teams
2. Group outputs logically — one `outputs.tf` per module / layer
3. **Name consistently**:
   - IDs → `vpc_id`, `subnet_private_ids`
   - ARNs → `role_arn`, `bucket_arn`
   - Endpoints → `alb_dns_name`, `rds_endpoint`
   - Collections → plural: `public_subnet_ids`
4. Prefer **simple values** over huge nested objects (easier consumption)
5. Use **precondition** blocks for critical invariants

```hcl
output "instance_count" {
  value = length(aws_instance.app)
  precondition {
    condition     = length(aws_instance.app) >= 2
    error_message = "At least 2 instances required for HA."
  }
}
```

6. **Never output plaintext secrets** to root module unless necessary — prefer Vault, SSM, Secrets Manager references
7. In modules → expose **minimal necessary** outputs (contract with consumers)
8. Use **depends_on** only when Terraform inference fails (rare)
9. Document outputs in module **README.md** (inputs + outputs table)
10. Avoid `sensitive = false` on root outputs containing credentials — even temporarily
11. In CI/CD → parse `terraform output -json` → feed to next steps (Ansible, kubectl, etc.)
12. **Large / computed outputs** — consider `nonsensitive()` only on derived safe values
13. **Version modules** — changing outputs is a breaking change → major version bump

## 6. Common Patterns

**Module consumption example**

```hcl
# root main.tf
module "vpc" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16"
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids   # list(string)
}
```

**Remote state usage**

```hcl
data "terraform_remote_state" "network" {
  backend = "s3"
  config = { ... }
}

output "app_security_group_id" {
  value = aws_security_group.app.id
  description = "Attach this to app instances - depends on VPC"
}
```

**JSON-friendly structured output**

```hcl
output "connection_info" {
  description = "All info needed to connect"
  value = {
    host     = aws_db_instance.main.endpoint
    port     = 5432
    user     = "admin"
    password = aws_db_instance.main.password   # sensitive
  }
  sensitive = true
}
```

## 7. Quick Troubleshooting Checklist

- `<sensitive>` everywhere? → Forgot to set / override `sensitive = true` on root output
- `Error: Output refers to sensitive values`? → Add `sensitive = true` to root output
- Value missing / `<computed>`? → Resource not created yet or depends_on missing
- Want to force refresh outputs only? → `terraform apply -refresh-only`
- Secret leaked in logs? → Check `-json`/`-raw` usage in CI
- Module output not visible? → Reference it in root `output` block
