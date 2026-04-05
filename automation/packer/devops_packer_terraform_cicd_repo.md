# DevOps Image Pipeline: Packer + Terraform + CI/CD 🏗️

## 1. Repository Structure

```
infra-repo/
├── packer/
│   ├── aws/
│   │   └── ami.pkr.hcl
│   ├── proxmox/
│   │   └── template.pkr.hcl
│   ├── scripts/
│   │   └── install.sh
│   └── variables.pkr.hcl
│
├── terraform/
│   ├── aws/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── proxmox/
│       └── main.tf
│
├── ci-cd/
│   ├── github-actions.yml
│   └── gitlab-ci.yml
│
└── README.md
```

---

## 2. Packer Config - AWS AMI

```hcl
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

source "amazon-ebs" "ubuntu" {
  region        = "us-east-1"
  instance_type = "t2.micro"
  source_ami    = "ami-0c55b159cbfafe1f0"
  ssh_username  = "ubuntu"
  ami_name      = "custom-ami-{{timestamp}}"
}

build {
  sources = ["source.amazon-ebs.ubuntu"]

  provisioner "shell" {
    script = "../scripts/install.sh"
  }
}
```

---

## 3. Packer Config - Proxmox Template

```hcl
source "proxmox-iso" "ubuntu" {
  proxmox_url = "https://proxmox.local:8006/api2/json"
  username    = "root@pam"
  password    = "password"

  vm_name  = "packer-template"
  iso_file = "local:iso/ubuntu.iso"
}

build {
  sources = ["source.proxmox-iso.ubuntu"]

  provisioner "shell" {
    inline = ["echo Proxmox template ready"]
  }
}
```

---

## 4. Terraform AWS Example

```hcl
provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "latest" {
  most_recent = true
  owners      = ["self"]
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.latest.id
  instance_type = "t2.micro"
}
```

---

## 5. Terraform Proxmox Example

```hcl
resource "proxmox_vm_qemu" "vm" {
  name        = "k8s-node"
  target_node = "pve"

  clone = "packer-template"

  cores  = 2
  memory = 2048
}
```

---

## 6. CI/CD - GitHub Actions

```yaml
name: Build Image

on:
  push:
    branches: [ "main" ]

jobs:
  packer:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Setup Packer
        uses: hashicorp/setup-packer@main

      - name: Init
        run: packer init packer/aws

      - name: Validate
        run: packer validate packer/aws

      - name: Build
        run: packer build packer/aws
```

---

## 7. CI/CD - GitLab CI

```yaml
stages:
  - build

packer:
  stage: build
  script:
    - packer init packer/aws
    - packer validate packer/aws
    - packer build packer/aws
```

---

## 8. install.sh Example

```bash
#!/bin/bash
apt update
apt install -y docker.io
systemctl enable docker
```

---

## 9. Workflow Summary

1. Developer pushes code
2. CI/CD triggers Packer build
3. Image created (AMI / Template)
4. Terraform deploys infrastructure

---

## 10. Best Practices

- Use versioned images
- Store secrets securely
- Separate environments (dev/staging/prod)
- Automate testing

---

🔥 Production-ready DevOps pipeline foundation
