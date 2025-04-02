output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.server[*].id
}

output "instance_private_ips" {
  value = aws_instance.server[*].private_ip
}
