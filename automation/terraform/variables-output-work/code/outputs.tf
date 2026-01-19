# Print public IP of the server
output "server_public_ip" {
  description = "Public IP of the server"
  value       = aws_instance.server1.public_ip
}

# Print connection guide
output "connection_guide" {
  value = "Access: ssh ubuntu@${aws_instance.server1.public_ip}"
}