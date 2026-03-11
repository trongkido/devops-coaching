variable "region" {
  default = "ap-northeast-2"
}

variable "enable_provisioner" {
  type    = bool
  default = true
}

variable "ami" {
  type    = string
  default = "ami-0ecfdfd1c8ae01aec"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = "ec2-key"
}

variable "key_path" {
  type    = string
  default = "~/.ssh/ec2-key.pem"
}

variable "security_group_ids" {
  type    = list(string)
  default = ["sg-0bd171fd5b491ad8f"]
}
