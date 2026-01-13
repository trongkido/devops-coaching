provider "aws" {
  profile = "trong-aws"
  region  = "ap-northeast-2"
}

provider "aws" {
  alias  = "dr_region"
  profile = "trong-aws"
  region = "us-east-1"
}

resource "random_id" "lab_id" {
  byte_length = 4
  keepers = {
    env = var.project_config.env
  }
}

resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = format("devops-lab-key-%s-%s", var.project_config.env, random_id.lab_id.hex)
  public_key = tls_private_key.ssh_key.public_key_openssh

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "aws_key_pair" "generated_key_dr" {
  provider = aws.dr_region
  key_name   = format("devops-lab-key-dr-%s-%s", var.project_config.env, random_id.lab_id.hex)
  public_key = tls_private_key.ssh_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  content         = tls_private_key.ssh_key.private_key_pem
  filename        = "${path.module}/generated-key.pem"
  file_permission = "0400"
}

resource "aws_iam_user" "sysadmins" {
  for_each = var.sysadmin_users

  name = "user-${each.key}-${random_id.lab_id.hex}"
  tags = {
    Department = each.value
    Role       = "SystemOperator"
  }
}

resource "aws_security_group" "devops-lab-sg" {
  name        = "devops-lab-sg-${var.project_config.env}-${random_id.lab_id.hex}"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.project_config.whitelist_ips
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "web_server" {
  count = var.project_config.instance_count

  depends_on = [
    aws_iam_user.sysadmins,
    aws_key_pair.generated_key
  ]

  ami           = data.aws_ami.ubuntu.id
  instance_type = var.project_config.env == "prod" ? var.project_config.instance_size["prod"] : var.project_config.instance_size["dev"]

  vpc_security_group_ids = [aws_security_group.devops-lab-sg.id]
  key_name               = aws_key_pair.generated_key.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update
              sudo apt-get install -y nginx
              echo "<h1>Server #${count.index + 1} (${var.project_config.env})</h1>" > /var/www/html/index.html
              sudo systemctl enable nginx
              sudo systemctl start nginx
              EOF

  tags = {
    Name = "WebServer-${upper(var.project_config.env)}-${count.index}-${random_id.lab_id.hex}"
  }
}

