############################################
# Generate SSH key
############################################
resource "tls_private_key" "vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

############################################
# Save SSH keys to local
############################################
resource "local_file" "private_key" {
  content         = tls_private_key.vm_ssh_key.private_key_openssh
  filename        = "${path.module}/keys/id_rsa"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content         = tls_private_key.vm_ssh_key.public_key_openssh
  filename        = "${path.module}/keys/id_rsa.pub"
  file_permission = "0600"
}

data "local_file" "root_ssh_public_key" {
  filename   = "${path.module}/keys/id_rsa.pub"
  depends_on = [local_file.private_key, local_file.public_key]
}

############################################
# Generate template VM
############################################
module "template" {
  source = "./modules/proxmox/create_template"

  template_name          = var.template_name
  proxmox_node           = var.proxmox_node
  vm_id                  = var.vm_id
  ssh_key                = trimspace(data.local_file.root_ssh_public_key.content)
  template_root_password = var.template_root_password

  image_url = var.image_url
}

##################################################
# Clone VM from template and initialize database
##################################################
module "proxmox" {
  source = "./modules/proxmox/clone_vm"

  proxmox_node   = var.proxmox_node
  template_vm_id = module.template.template_id
  db_vm_id       = var.db_vm_id
  db_vm_name     = var.db_vm_name
  db_ip_address  = var.db_ip_address
  db_gateway     = var.db_gateway

  vm_user          = var.vm_user
  vm_password      = var.vm_password
  ssh_key          = trimspace(data.local_file.root_ssh_public_key.content)
  ssh_private_key  = tls_private_key.vm_ssh_key.private_key_openssh
  db_root_password = var.db_root_password
  db_app_user      = var.db_app_user
  db_app_password  = var.db_app_password
  db_app_schema    = var.db_app_schema
  db_disk_size     = var.db_disk_size

  vm_memory = var.vm_memory
  vm_cores  = var.vm_cores
}
