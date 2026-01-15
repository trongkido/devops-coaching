provider "aws" {
  profile = "trong-aws"
  region  = "ap-northeast-2"
}

/*
This looks up an existing VPC by ID.
The VPC ID is hardcoded (vpc-050e94a4923a4a283), so it's not dynamically discovered.
*/

/* Example
data "aws_vpc" "app-vpc" {
  id = "vpc-050e94a4923a4a283"
}
*/

# Read data from vpc with filter
data "aws_vpc" "my-vpc" {
  filter {
    name   = "tag:Name"
    values = ["eksctl-trong-lab-eks-cluster-cluster*"]
  }
}

/*
This retrieves all subnets in the specified VPC.
It filters subnets based on:
   The vpc-id matching the VPC found above.
  The subnet must be tagged: alb_subnet = "public".
So it’s looking for subnets marked as public, likely meant for exposing resources via an ALB
*/
data "aws_subnets" "all" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.my-vpc.id]
  }
  tags = {
    alb_subnet = "public"
  }
}
