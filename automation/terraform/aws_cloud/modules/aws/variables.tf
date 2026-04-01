# VPC Variables
variable "create_vpc" {
  type    = bool
  default = true
}

variable "vpc_cidr" {
  default = "10.0.0.0/16"
}

variable "existing_vpc_id" {
  type    = string
  default = ""
}