output "template_id" {
  description = "Proxmox VM ID of the template VM"
  value       = module.template.template_id
}

output "ssh_command" {
  description = "SSH command to connect to the template VM"
  value       = "ssh -o StrictHostKeyChecking=no -i ./keys/id_rsa root@vm_ip"
}

output "db_vm_name" {
  description = "Database VM name on Proxmox"
  value       = module.proxmox.db_vm_name
}

output "db_vm_ip" {
  description = "Static IP address of the database VM"
  value       = module.proxmox.db_vm_ip
}

output "db_vm_id" {
  description = "Proxmox VM ID of the database server"
  value       = module.proxmox.db_vm_id
}