provider "aws" {
  profile = "trong-aws"
  region  = "ap-northeast-2"
}

module "ec2_instance" {

  source = "./modules/ec2"

  ami           = var.ami
  instance_type = var.instance_type
  key_name      = var.key_name
  key_path      = var.key_path
  security_group_ids = var.security_group_ids

  enable_provisioner = var.enable_provisioner
}

resource "aws_instance" "Server1" {
  ami           = "vami-0cf1ead55e8259a57"
  instance_type = "t3.small"

  tags = {
    Name = "Server1"
  }
}
