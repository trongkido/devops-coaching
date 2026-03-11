variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
}

variable "key_name" {
  type = string
}

variable "key_path" {
  type = string
}

variable "security_group_ids" {
  description = "Existing Security Groups"
  type        = list(string)
}

variable "enable_provisioner" {
  description = "Enable provisioner"
  type        = bool
  default     = true
}