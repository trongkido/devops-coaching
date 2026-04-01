# HashiCorp Packer Complete Guide 🧱

## 1. What is Packer?
Packer is an open-source tool by HashiCorp used to create identical machine images for multiple platforms from a single source configuration.

---

## 2. Why Use Packer?

- Immutable infrastructure
- Faster deployments
- Consistent environments
- Multi-cloud image builds

---

## 3. Core Concepts

### Builders
Responsible for creating images for specific platforms.

Examples:
- amazon-ebs (AWS AMI)
- azure-arm
- googlecompute
- docker
- proxmox

---

### Provisioners
Used to install software and configure the image.

Types:
- shell
- ansible
- file
- powershell

Example:
```hcl
provisioner "shell" {
  inline = [
    "apt update",
    "apt install -y nginx"
  ]
}
```

---

### Post-Processors
Used after image creation.

Examples:
- compress
- docker-tag
- manifest

---

## 4. Packer Template (HCL2)

Example:
```hcl
packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = ">= 1.0.0"
    }
  }
}

source "amazon-ebs" "example" {
  region        = "us-east-1"
  instance_type = "t2.micro"
  ami_name      = "packer-example-{{timestamp}}"
  source_ami    = "ami-123456"
  ssh_username  = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.example"]

  provisioner "shell" {
    inline = ["echo Hello Packer"]
  }
}
```

---

## 5. Packer Workflow

1. packer init
2. packer fmt
3. packer validate
4. packer build

---

## 6. Variables

```hcl
variable "region" {
  type    = string
  default = "us-east-1"
}
```

---

## 7. Using Variables

```hcl
region = var.region
```

---

## 8. Environment Variables

```bash
export PKR_VAR_region=us-west-2
```

---

## 9. File Structure

```
packer/
 ├── main.pkr.hcl
 ├── variables.pkr.hcl
 ├── scripts/
 │    └── install.sh
```

---

## 10. Provisioners Deep Dive

### Shell
```hcl
provisioner "shell" {
  script = "scripts/install.sh"
}
```

### Ansible
```hcl
provisioner "ansible" {
  playbook_file = "playbook.yml"
}
```

---

## 11. Builders Deep Dive

### AWS AMI
- Uses EC2 temporary instance
- Creates AMI

### Docker
- Builds container images

### Proxmox
- Creates VM templates

---

## 12. Debugging

```bash
PACKER_LOG=1 packer build .
```

---

## 13. Best Practices

- Keep images minimal
- Use versioning
- Avoid hardcoding
- Use CI/CD
- Separate build & deploy

---

## 14. Packer + Terraform

Workflow:
1. Packer builds image
2. Terraform deploys infrastructure using image

Example:
```hcl
ami = data.aws_ami.my_packer_image.id
```

---

## 15. CI/CD Integration

- GitHub Actions
- GitLab CI
- Jenkins

---

## 16. Security

- Avoid hardcoding secrets
- Use Vault
- Rotate credentials

---

## 17. Common Errors

- SSH timeout
- Wrong base image
- Missing dependencies

---

## 18. Advanced Topics

- Multi-builder pipelines
- Parallel builds
- Custom plugins
- Image pipelines

---

## 19. Learning Path

1. Basics
2. Build AMI
3. Provisioners
4. Multi-cloud builds
5. CI/CD automation

---

## 20. Summary

Packer helps you:
- Automate image creation
- Improve consistency
- Speed up deployments
- Enable immutable infrastructure

---

🔥 End of Guide
