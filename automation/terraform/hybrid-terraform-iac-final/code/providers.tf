terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">=0.80.0"
    }
  }
}

provider "proxmox" {
  endpoint = var.proxmox_endpoint
  # Token User
  api_token = "${var.proxmox_user_name}!${var.proxmox_api_token_id}=${var.proxmox_api_token}"
  insecure  = true

  ssh {
    agent    = false
    username = var.proxmox_ssh_user
    password = var.proxmox_ssh_password
  }
}