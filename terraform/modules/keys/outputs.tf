output "bastion_key" {
  description = "bastion key"
    value = {
    key_name        = aws_key_pair.bastion_key.key_name
    private_key_pem = tls_private_key.bastion_key.private_key_pem
  }
  sensitive = true
}

output "existing_key" {
  description = "existing key"
  value       = aws_key_pair.existing_key.key_name
}
