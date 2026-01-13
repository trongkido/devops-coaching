output "server_ips" {
  description = "List of IP addresses of the servers (Splat Operator)"
  value       = aws_instance.web_server[*].public_ip
}

output "generated_key_name" {
  description = "The Key Pair name has been generated (with a random ID)"
  value       = aws_key_pair.generated_key.key_name
}