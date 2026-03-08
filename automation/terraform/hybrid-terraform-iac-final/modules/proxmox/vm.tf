resource "proxmox_vm_qemu" "database_vm" {

  name        = "db-server"
  target_node = var.proxmox_host
  clone       = "ubuntu-template"

  cores  = 2
  memory = 2048

  network {
    model  = "virtio"
    bridge = "vmbr0"
  }
}
