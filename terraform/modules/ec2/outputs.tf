output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.server[*].id
}

output "bastion_public_key" {
  value = aws_key_pair.bastion_key.public_key
}