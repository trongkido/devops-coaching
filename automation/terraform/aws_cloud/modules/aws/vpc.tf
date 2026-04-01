data "aws_vpc" "default" {
  default = true
}

resource "aws_vpc" "this" {
  count = var.create_vpc ? 1 : 0

  cidr_block = var.vpc_cidr

  tags = {
    Name = "terraform-vpc"
  }
}
