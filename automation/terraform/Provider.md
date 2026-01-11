# Terraform Providers: The Bridge for Hybrid Cloud

If you are already familiar with Docker and Kubernetes but still find Terraform a bit *“magical”* and hard to grasp, this article is for you.

Today, we will demystify the most important concept in Terraform: **Providers**. Not just theory — we will build a **real Hybrid Cloud system**: creating a virtual network on **AWS** and a virtual machine on an **on‑premise Proxmox server** in a single Terraform run.

---

## 1. Mindset: What Is a Provider? (K8s Perspective)

Many people mistakenly believe that **Terraform Core** is an all‑powerful engine that knows how to control every cloud.  
The truth is quite the opposite.

Terraform Core is actually rather *“naive”*. Its responsibilities are limited to:
- Managing **state**
- Calculating the **dependency graph**

So who does the real work?  
👉 **Providers**.

### 💡 Kubernetes Analogy

- **Terraform Core** is like `kube-apiserver` or `docker CLI`: it receives commands but does not touch the infrastructure directly.
- **Providers** are like **CRI** (Container Runtime Interface) or **Cloud Controller Managers** in Kubernetes — they act as *translators*.

Example:
> When you say “Create a VM”, Terraform Core asks the Provider plugin:  
> *“Hey AWS Provider, translate this into AWS API calls for me.”*

The **Terraform Registry** is essentially an app marketplace (similar to Docker Hub or Artifact Hub), hosting thousands of providers for AWS, Azure, GCP, VMware, Proxmox, and more.

---

## 2. Hands‑on Lab: Hybrid Cloud (AWS & Proxmox)

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

---

## 3. Run the Lab & Verify

From the project directory:

### 1️⃣ Initialize

```bash
terraform init
```

Downloads AWS & Proxmox provider binaries and generates:
- `.terraform.lock.hcl`

📌 This file is **critical** (like `package-lock.json`).  
👉 **Commit it to Git**.

---

### 2️⃣ Plan

```bash
terraform plan
```

Terraform connects to **both AWS and Proxmox** and shows:
> “I am about to create 2 new resources.”

---

### 3️⃣ Apply

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

