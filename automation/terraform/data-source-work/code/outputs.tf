# Outputs the list of subnet IDs
output "all" {
  value = {
    public_subnets = data.aws_subnets.all.ids
  }
}