# Terraform Providers: The Bridge for Hybrid Cloud

If you are already familiar with Docker and Kubernetes but still find Terraform a bit *“magical”* and hard to grasp, this article is for you.

Today, we will demystify the most important concept in Terraform: **Providers**. Not just theory — we will build a **real Hybrid Cloud system**: creating a virtual network on **AWS** and a virtual machine on an **on‑premise Proxmox server** in a single Terraform run.

---

## 1. What Is a Provider? (K8s Perspective)

Many people mistakenly believe that **Terraform Core** is an all‑powerful engine that knows how to control every cloud.  
The truth is quite the opposite.

Terraform Core is actually rather *“naive”*. Its responsibilities are limited to:
- Managing **state**
- Calculating the **dependency graph**

So who does the real work?  
👉 **Providers**.

A **Terraform Provider** is a plugin that allows Terraform to interact with an external system via APIs.

Terraform itself **does not know** how to:
- Create a VM
- Provision a VPC
- Configure DNS
- Manage Kubernetes objects

All of this logic lives inside **Providers**.

### 💡 Kubernetes Analogy

- **Terraform Core** is like `kube-apiserver` or `docker CLI`: it receives commands but does not touch the infrastructure directly.
- **Providers** are like **CRI** (Container Runtime Interface) or **Cloud Controller Managers** in Kubernetes — they act as *translators*.

Example:
> When you say “Create a VM”, Terraform Core asks the Provider plugin:  
> *“Hey AWS Provider, translate this into AWS API calls for me.”*

The **Terraform Registry** is essentially an app marketplace (similar to Docker Hub or Artifact Hub), hosting thousands of providers for AWS, Azure, GCP, VMware, Proxmox, and more.

### Responsibilities of Terraform Core vs Provider

| Terraform Core | Provider |
|---------------|----------|
| Parses `.tf` files | Talks to external APIs |
| Builds dependency graph | Authenticates |
| Manages state | Creates / updates / deletes resources |
| Plans changes | Translates HCL → API calls |

## 2. Provider Architecture (Under the Hood)

```
Terraform CLI
   |
Terraform Core
   |
Provider Plugin (Binary)
   |
Target API (AWS, Azure, Proxmox, K8s, GitHub, etc.)
```

- Providers are **compiled binaries**
- Downloaded automatically during `terraform init`
- Cached locally under `.terraform/providers/`

## 3. Types of Providers

| Type | Source | Example |
|----|------|--------|
| Official | HashiCorp | aws, azurerm, google |
| Partner | Verified vendors | cloudflare, datadog |
| Community | Open-source | telmate/proxmox |
| Local / Custom | Self-built | Internal systems |

Syntax:
```hcl
required_providers {
  aws = {
    source  = "hashicorp/aws"
    version = "~> 5.0"
  }
}
```

## 4. Provider Versioning (CRITICAL)

### Why Pin Versions?

❌ Without version pinning:
- Breaking changes
- Unexpected behavior
- CI/CD failures

✅ With version pinning:
- Reproducible builds
- Stable pipelines

### Common Version Constraints

| Constraint | Meaning |
|---------|---------|
| `= 1.2.3` | Exact |
| `~> 5.0` | Any `5.x` |
| `>= 1.5.0` | Minimum |
| `< 6.0` | Upper bound |

## 5. Terraform `.terraform.lock.hcl` file (VERY IMPORTANT)

- Locks exact provider versions and checksums
- Similar to `package-lock.json`
- Must be **committed to Git**

Commands:
```bash
terraform init
terraform init -upgrade
```

## 6. Multiple Provider Instances (Aliases)

Used for:
- Multi-region
- Multi-account
- Multi-cluster

```hcl
provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "singapore"
  region = "ap-southeast-1"
}

resource "aws_vpc" "sg" {
  provider = aws.singapore
  cidr_block = "10.1.0.0/16"
}
```

## 7. Authentication Patterns

Common Methods

| Method | Example |
|-----|--------|
| Env Vars | AWS_ACCESS_KEY_ID |
| API Token | Proxmox, GitHub |
| IAM Role | EC2, EKS |
| Certificate | Vault, TLS |
| OIDC | Modern CI/CD |

## 8. Provider vs Resource vs Data Source

| Type | Purpose |
|----|--------|
| Provider | API integration |
| Resource | Create/manage |
| Data Source | Read-only lookup |

Example:
```hcl
data "aws_ami" "ubuntu" {
  most_recent = true
}
```

## 9. Provider Dependencies & Graph

Terraform builds a **dependency graph** using:
- References
- `depends_on`
- Implicit relationships

Providers are initialized **before** resources.

## 10. Error Handling & Debugging

### Enable Debug Logs
```bash
TF_LOG=TRACE terraform plan
```

### Common Errors

| Error | Root Cause |
|----|----------|
| 401 Unauthorized | Bad credentials |
| Timeout | Network / permission |
| Provider not found | Wrong source |
| Incompatible version | Constraint mismatch |

## 11. Hybrid & Multi-Cloud Patterns

Terraform supports **multiple providers in one project**.

Example:
- AWS → Production
- Proxmox → Dev
- Cloudflare → DNS
- Kubernetes → Runtime

Single `terraform apply` controls everything.

## 12. Provider Lifecycle

1. `terraform init`
2. Download provider
3. Authenticate
4. CRUD operations
5. Update state

Providers are **stateless** — state is owned by Terraform.

## 13. Writing Custom Providers (Advanced)

Use cases:
- Internal platforms
- Legacy APIs
- Custom SaaS

Tech stack:
- Go
- Terraform Plugin Framework

Not recommended unless necessary.

## 14. Security Best Practices

✅ Do:
- Least-privilege IAM roles
- Separate tokens per environment
- Rotate credentials
- Use Vault / SSM

❌ Avoid:
- Root credentials
- Plaintext secrets
- Shared tokens

## 15. CI/CD Best Practices

- Pin provider versions
- Commit lock file
- Use `terraform init -input=false`
- Use OIDC instead of static secrets

## 16. Real-World Pro Tips

- Providers ≠ Resources
- Providers are replaceable, state is not
- Always read provider CHANGELOG
- Community providers may lag behind APIs
- Prefer official providers when possible

## 17. Mental Model (Final Takeaway)

- Terraform Core is a **planner**.  
- Providers are **workers**.  
- APIs do the **real work**.

If you understand this — Terraform becomes predictable, not magical.

---

## 18. Hands‑on Lab: Hybrid Cloud (AWS & Proxmox)

### Scenario

Your company:
- Uses **AWS** for Production
- Uses **on‑premise Proxmox** for Dev/Test to save costs

You want **one Terraform codebase** to manage both.

---

## Project Structure

Clean code mindset from day one — do **not** put everything into a single file.

```text
lab-providers/
├── providers.tf      # Provider definitions (the translators)
├── main.tf           # Resource definitions
├── variables.tf      # Variable declarations
└── terraform.tfvars  # Secrets (NEVER commit to Git)
```

---

## Step 1: Configure Providers (`providers.tf`) — Most Important

This file tells Terraform **which plugins to download**.  
We will use two providers:

- **AWS**: Official provider (HashiCorp)
- **Proxmox**: Community provider (telmate/proxmox)

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

# AWS Provider
provider "aws" {
  region = "ap-southeast-1" # Singapore
  # Best practice: use environment variables for AWS credentials
}

# Proxmox Provider
provider "proxmox" {
  pm_api_url      = var.pm_api_url
  pm_user         = var.pm_user
  pm_password     = var.pm_password
  pm_tls_insecure = true # Lab only (self-signed cert)
}
```

---

## Step 2: Define Resources (`main.tf`)

We will:
- Create a **VPC** on AWS
- Create an **Ubuntu VM** on Proxmox

```hcl
# --- AWS RESOURCE ---
resource "aws_vpc" "lab_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name        = "trongnvlab-vpc"
    Environment = "Education"
  }
}

# --- PROXMOX RESOURCE ---
# Requirement: an existing template named "ubuntu-2004-template"
resource "proxmox_vm_qemu" "lab_vm" {
  name        = "student-vm-01"
  target_node = "pve-01"
  clone       = "ubuntu-2004-template"

  cores   = 2
  sockets = 1
  memory  = 2048

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }

  disk {
    storage = "local-lvm"
    type    = "scsi"
    size    = "10G"
  }
}
```

---

## Step 3: Declare Variables (`variables.tf`)

```hcl
variable "pm_api_url" {
  description = "Proxmox API URL, e.g. https://192.168.1.100:8006/api2/json"
}

variable "pm_user" {
  default = "root@pam"
}

variable "pm_password" {
  sensitive = true
}
```

⚠️ **Important**: Put real values in `terraform.tfvars`.  
**Never hardcode passwords** in `.tf` files.
Use **environment variables** for credentials

---

## 3. Run the Lab & Verify

From the project directory:

### Initialize

```bash
terraform init
```

Downloads AWS & Proxmox provider binaries and generates:
- `.terraform.lock.hcl`

📌 This file is **critical** (like `package-lock.json`).  
👉 **Commit it to Git**.

---

### Plan

```bash
terraform plan
```

Terraform connects to **both AWS and Proxmox** and shows:
> “I am about to create 2 new resources.”

---

### Apply

```bash
terraform apply
```

Type `yes`.

After a few minutes:
- AWS Console → VPC
- Proxmox UI → VM `student-vm-01` running

---

## 🚀 Tip

When working in a team:
- If you update provider versions in `providers.tf`
- Always run:

```bash
terraform init -upgrade
```

This keeps the provider lock file in sync across the team.

