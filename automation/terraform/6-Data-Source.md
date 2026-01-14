# Terraform Data Sources – Complete Knowledge & Best Practices Guide

This document is a **comprehensive, production-ready reference** covering everything you need to know about **Terraform Data Sources**: what they are, how they work, when to use them, and best practices at scale.

---

## 1. What Is a Terraform Data Source?

A **data source** allows Terraform to **read information from existing infrastructure** without creating or modifying it.

> 🔑 Data sources are **read-only**.

They answer questions like:
- What is the latest AMI?
- What is the ID of an existing VPC?
- What IPs belong to this load balancer?
- What secrets already exist?

---

## 2. Data Source vs Resource (Critical Difference)

| Aspect | Resource | Data Source |
|-----|--------|-----------|
| Creates infrastructure | ✅ Yes | ❌ No |
| Updates infrastructure | ✅ Yes | ❌ No |
| Deletes infrastructure | ✅ Yes | ❌ No |
| Reads existing data | ⚠️ Limited | ✅ Yes |
| Appears in state | ✅ Full | ✅ Cached read-only |

> 🧠 **Mental Model**  
> Resource = “Terraform owns it”  
> Data Source = “Terraform observes it”

---

## 3. Basic Syntax

```hcl
data "<PROVIDER>_<TYPE>" "<NAME>" {
  # filters / arguments
}
```

Example:

```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}
```

Usage:

```hcl
ami = data.aws_ami.ubuntu.id
```

---

## 4. Commonly Used Data Sources

### AWS
- `aws_ami`
- `aws_vpc`
- `aws_subnets`
- `aws_security_group`
- `aws_caller_identity`
- `aws_region`
- `aws_availability_zones`
- `aws_lb`
- `aws_secretsmanager_secret_version`

### Kubernetes
- `kubernetes_service`
- `kubernetes_namespace`
- `kubernetes_config_map`

### Cloud / Infra
- `google_compute_network`
- `azurerm_resource_group`
- `proxmox_vm_qemu`
- `vsphere_datacenter`

---

## 5. Filtering & Selection

Use filters carefully to avoid ambiguity.

```hcl
data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = ["main-vpc"]
  }
}
```

⚠️ If multiple matches occur → Terraform fails.

---

## 6. Using Data Sources with Meta-Arguments

### Depends_on (Rare but valid)

```hcl
data "aws_ami" "custom" {
  depends_on = [aws_instance.builder]
}
```

### For_each with Data Sources

```hcl
data "aws_subnet" "selected" {
  for_each = toset(var.subnet_ids)
  id       = each.value
}
```

---

## 7. Data Sources in Modules

Best practice: **pass IDs, not data sources**, into modules.

❌ Bad:
```hcl
data "aws_vpc" "main" {}
module "app" {
  vpc_id = data.aws_vpc.main.id
}
```

✔ Good:
```hcl
module "app" {
  vpc_id = var.vpc_id
}
```

---

## 8. Data Source Evaluation Timing

- Evaluated at **plan time**
- Re-evaluated if inputs change
- Cached in state (read-only)

---

## 9. Data Sources and State

- Stored in `terraform.tfstate`
- Marked as **data**
- Do not cause drift
- Do not support import

---

## 10. Error Patterns & Debugging

### Error: no matching resource found
- Filter too strict
- Wrong region/provider

### Error: multiple results found
- Filter too loose

Debug with:

```bash
terraform console
> data.aws_ami.ubuntu.id
```

---

## 11. Security Considerations

- Secrets read via data sources are stored in state
- Always encrypt remote state
- Use IAM least privilege

```hcl
data "aws_secretsmanager_secret_version" "db" {
  secret_id = "prod/db/password"
}
```

---

## 12. Best Practices (Must-Follow)

✅ Use data sources for:
- Existing infrastructure
- Environment discovery
- Shared resources

❌ Avoid:
- Overusing data sources inside modules
- Broad filters
- Environment-specific logic

---

## 13. Real-World Patterns

### Latest AMI Pattern
```hcl
ami = data.aws_ami.ubuntu.id
```

### Account Awareness
```hcl
data "aws_caller_identity" "current" {}
```

### Multi-Region Awareness
```hcl
data "aws_region" "current" {}
```

---

## 14. Terraform Design Rule

> **Resources create.  
> Data sources discover.  
> State remembers.  
> Providers translate.**
