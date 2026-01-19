provider "aws" {
  profile = "trong-aws"
  region  = "ap-northeast-2"
}

# Use Data Source to find the newest Ubuntu AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical Owner ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# --- Local custom variables ---
locals {
  full_server_name = "${var.project_name}-${var.environment}"

  common_tags = {
    Owner       = "TrongNguyen"
    ManagedBy   = "Terraform"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
  }
}

# --- RESOURCE: Create VM ---
resource "aws_instance" "server1" {
  # Get ID from Data Source
  ami = data.aws_ami.ubuntu.id

  instance_type = var.instance_type

  tags = merge(
    local.common_tags,
    {
      Name = local.full_server_name
    }
  )
}