output "db_vm_ip" {
  description = "Static IP address of the database VM"
  value       = var.db_ip_address
}

output "db_vm_id" {
  description = "Proxmox VM ID of the database server"
  value       = proxmox_virtual_environment_vm.database.vm_id
}

output "db_vm_name" {
  description = "Name of the database VM"
  value       = proxmox_virtual_environment_vm.database.name
}