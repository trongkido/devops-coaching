############################################
# 1. Download cloud image (auto)
############################################
resource "proxmox_virtual_environment_download_file" "cloud_image" {
  content_type = "import"
  datastore_id = "local"
  node_name    = var.proxmox_node

  url = var.image_url
}

############################################
# 3. Create VM template
############################################
resource "proxmox_virtual_environment_vm" "template" {
  name      = var.template_name
  node_name = var.proxmox_node
  vm_id     = var.vm_id

  template = true
  started  = false

  machine = "q35"
  bios    = "ovmf"
  description = "Managed by Terraform"

  cpu {
    cores = 1
  }

  memory {
    dedicated = 2048
  }

  efi_disk {
    datastore_id = "local-lvm"
    type         = "4m"
  }

  ##########################################
  # OS disk from downloaded image
  ##########################################
  disk {
    datastore_id = "local-lvm"
    file_id      = proxmox_virtual_environment_download_file.cloud_image.id
    interface    = "virtio0"
    iothread     = true
    discard      = "on"
    size         = 10
  }

  ##########################################
  # Cloud-init
  ##########################################
  initialization {
    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      username = var.template_user
      password = var.template_root_password
      keys     = [var.ssh_key]
    }
  }

  ##########################################
  # Network
  ##########################################
  network_device {
    bridge = "vmbr0"
    model  = "virtio"
  }

  ##########################################
  # Guest agent
  ##########################################
  agent {
    enabled = true
  }

  operating_system {
    type = "l26"
  }
}