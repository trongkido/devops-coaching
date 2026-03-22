variable "image_url" {
  description = "URL of the image to use for the template VM"
  type        = string
}

variable "template_name" {
  default = "rocky9-template"
}

variable "template_user" {
    description = "Template user name"
    type        = string
    default     = "root"
}

variable "proxmox_node" {
    description = "Proxmox node name"
    type        = string
    default     = "pve"
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

variable "ssh_key" {
    description = "SSH public key for root user"
    type        = string
    sensitive   = true
}

variable "template_root_password" {
  description = "Plain text root password for template"
  type        = string
  sensitive   = true
}