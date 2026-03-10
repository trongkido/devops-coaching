provider "aws" {
  profile = "trong-aws"
  region  = "ap-northeast-2"
}

module "ec2_instance" {

  source = "./modules/ec2"

  ami           = "ami-0c02fb55956c7d316"
  instance_type = "t2.micro"

}

