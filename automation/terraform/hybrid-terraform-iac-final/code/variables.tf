# Proxmox Variables
variable "proxmox_endpoint" {
  type        = string
  description = "Proxmox API endpoint URL"
}

variable "proxmox_user_name" {
  type        = string
  description = "Proxmox user name"
}

variable "proxmox_api_token_id" {
  type        = string
  description = "Proxmox API token ID"
}

variable "proxmox_api_token" {
  type        = string
  sensitive   = true
  description = "Proxmox API token"
}

variable "proxmox_node" {
  type        = string
  default     = "pve"
  description = "Proxmox node name"
}

variable "proxmox_ssh_user" {
  type        = string
  description = "Proxmox SSH user name"
}

variable "proxmox_ssh_password" {
  type        = string
  sensitive   = true
  description = "Proxmox SSH password"
}

## Template Variables
variable "image_url" {
  description = "URL of the image to use for the template VM"
  type        = string
}

variable "template_name" {
  default = "rocky9-template"
}

variable "vm_id" {
  description = "VM ID for template"
  type        = number
  default     = 101
}

variable "snippet_datastore" {
  description = "Datastore for snippets"
  type        = string
  default     = "local"
}

variable "template_root_password" {
  type        = string
  sensitive   = true
  description = "Root password for template VM"
}

# Shared Variables
variable "project_name" {
  type    = string
  default = "hybrid-lab"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "template_vm_id" {
  type        = number
  default     = 100
  description = "VM template ID to clone from"
}

variable "db_vm_id" {
  type        = number
  default     = 200
  description = "VM ID for database server"
}

variable "db_vm_name" {
  type        = string
  default     = "db-server-01"
  description = "VM name for database server"
}

variable "vm_memory" {
  type        = number
  default     = 2048
  description = "RAM in MB"
}

variable "vm_cores" {
  type        = number
  default     = 1
  description = "Number of CPU cores"
}

variable "db_ip_address" {
  type        = string
  default     = "192.168.88.100/24"
  description = "Static IP for database VM (CIDR notation)"
}

variable "db_gateway" {
  type        = string
  default     = "192.168.88.1"
  description = "Default gateway for DB VM"
}

variable "db_disk_size" {
  type        = number
  default     = 8
  description = "Disk size for database VM in GB"
}

variable "vm_user" {
  type        = string
  default     = "root"
  description = "VM user for SSH connection"
}

variable "vm_password" {
  type        = string
  sensitive   = true
  description = "VM user password for SSH connection"
}

#variable "ssh_key" {
#  type        = string
#  sensitive   = true
#  description = "SSH public key for VM user"
#}

variable "db_root_password" {
  type        = string
  sensitive   = true
  description = "Database root password"
}

variable "db_app_user" {
  type        = string
  default     = "db-app-user"
  description = "Database application user"
}

variable "db_app_password" {
  type        = string
  sensitive   = true
  description = "Database application password"
}

variable "db_app_schema" {
  type        = string
  default     = "db-app-schema"
  description = "Database application schema"
}