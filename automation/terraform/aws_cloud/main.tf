module "aws" {
  source = "./modules/aws"
  
  create_vpc = var.create_vpc
  vpc_cidr   = var.vpc_cidr

  aws_profile = var.aws_profile
  aws_region  = var.aws_region

}
