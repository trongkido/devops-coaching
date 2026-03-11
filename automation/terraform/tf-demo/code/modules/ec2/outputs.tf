output "instance_id" {
  value = aws_instance.ec2_module_demo.id
}

output "public_ip" {
  value = aws_instance.ec2_module_demo.public_ip
}
