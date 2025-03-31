output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "bastion_sg_id" {
  description = "Security Group ID for the bastion host"
  value       = aws_security_group.bastion_sg.id
}

output "private_sg_id" {
  description = "Security Group ID for private EC2 instances"
  value       = aws_security_group.private_sg.id
}