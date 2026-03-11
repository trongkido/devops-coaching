output "vm_ip" {
  value = proxmox_vm_qemu.database_vm.default_ipv4_address
}
