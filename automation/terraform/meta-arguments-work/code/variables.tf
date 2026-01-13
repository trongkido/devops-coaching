variable "project_config" {
  type = object({
    env            = string
    instance_size  = map(string)
    whitelist_ips  = list(string)
    instance_count = number
  })

  default = {
    env = "dev"
    instance_size = {
      dev  = "t3.micro"
      prod = "t3.medium"
    }
    whitelist_ips  = ["0.0.0.0/0"]
    instance_count = 2
  }
}

variable "sysadmin_users" {
  description = "Admin users list (Map)"
  type        = map(string)
  default = {
    "alice" = "DevOps-Lead"
    "bob"   = "SysAdmin-Intern"
  }
}