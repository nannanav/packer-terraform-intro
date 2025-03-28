variable "instance_count" {
  description = "Number of instances to create"
  type        = number
}

variable "subnet_id" {
  description = "Subnet ID for EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  type        = string
}

variable "key_name" {
  description = "SSH key pair name"
  type        = string
}

variable "security_groups" {
  description = "List of security groups for the EC2 instances"
  type        = list(string)
}
