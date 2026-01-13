provider "aws" {
  profile = "trong-aws"
  region  = "ap-northeast-2"
}

resource "aws_instance" "ec2-terraform" {
  ami           = "ami-0b818a04bc9c2133c"
  instance_type = "t2.micro"
  key_name      = "eks-worker"
  tags = {
    Name = "ec2-terrafrom"
  }
}