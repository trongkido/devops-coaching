module "aws_infrastructure" {
  source = "./modules/aws"

  aws_region = var.aws_region
}

module "proxmox_database" {
  source = "./modules/proxmox"

  proxmox_host = "pve-node1"
}
