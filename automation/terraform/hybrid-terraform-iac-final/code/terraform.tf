terraform {
  cloud {
    organization = "hybrid-cloud-lab"

    workspaces {
      name = "hybrid-infra"
    }
  }

  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }

    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.11"
    }
  }
}
