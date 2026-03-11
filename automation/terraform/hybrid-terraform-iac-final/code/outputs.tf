output "alb_dns" {
  value = module.aws_infrastructure.alb_dns
}

output "database_vm_ip" {
  value = module.proxmox_database.vm_ip
}
