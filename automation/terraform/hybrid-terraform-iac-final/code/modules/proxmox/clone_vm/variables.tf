variable "proxmox_node" {
  type        = string
  default     = "pve"
  description = "Proxmox node name"
}

variable "template_vm_id" {
  description = "VM template ID to clone from"
  type        = number
}

variable "db_vm_id" {
  description = "VM ID for database server"
  type        = number
  default     = 200
}

variable "db_vm_name" {
  description = "VM name for database server"
  type        = string
  default     = "db-server-01"
}

variable "vm_memory" {
  description = "RAM in MB"
  type        = number
  default     = 2048
}

variable "vm_cores" {
  description = "Number of CPU cores"
  type        = number
  default     = 1
}

variable "db_ip_address" {
  description = "Static IP for database VM (CIDR notation)"
  type        = string
  default     = "192.168.88.100/24"
}

variable "db_gateway" {
  description = "Default gateway for DB VM"
  type        = string
  default     = "192.168.88.1"
}

variable "db_disk_size" {
  description = "Disk size for database VM in GB"
  type        = number
  default     = 10
}

variable "vm_user" {
  description = "VM user for SSH connection"
  type        = string
  default     = "root"
}

variable "vm_password" {
  description = "VM user password for SSH connection"
  type        = string
  sensitive   = true
}

variable "ssh_key" {
  description = "SSH public key for VM root user"
  type        = string
  sensitive   = true
}

variable "ssh_private_key" {
  description = "SSH private key for VM connection"
  type        = string
  sensitive   = true
}

variable "db_root_password" {
  description = "Database root password"
  type        = string
  sensitive   = true
}

variable "db_app_user" {
  description = "Database application user"
  type        = string
  default     = "db-app-user"
}

variable "db_app_password" {
  description = "Database application password"
  type        = string
  sensitive   = true
}

variable "db_app_schema" {
  description = "Database application schema"
  type        = string
  default     = "db-app-schema"
}