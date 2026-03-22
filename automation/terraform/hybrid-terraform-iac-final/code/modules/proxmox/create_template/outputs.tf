output "template_id" {
  description = "Proxmox VM ID of the template VM"
  value = proxmox_virtual_environment_vm.template.vm_id
}