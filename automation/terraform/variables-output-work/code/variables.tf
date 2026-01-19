# 1. Projectname (Required)
variable "project_name" {
  type        = string
  description = "Name of your project"
  default     = "devops-coaching"
}

# 2. Running Environment (required)
variable "environment" {
  type        = string
  description = "Running environment (dev, prod, staging)"
}

# 3. EC2 type (default: t2.micro)
variable "instance_type" {
  type    = string
  default = "t2.micro"
}