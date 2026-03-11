provider "aws" {
  region = var.aws_region
}

provider "proxmox" {
  pm_api_url = var.pm_api_url
}
