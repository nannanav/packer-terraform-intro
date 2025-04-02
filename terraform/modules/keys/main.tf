resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}

resource "aws_key_pair" "existing_key" {
  key_name   = "existing_key"
  public_key = file(var.key_path)  # Read the public key from the path passed in var.key_path
}

# resource "null_resource" "generate_public_key" {
#   provisioner "local-exec" {
#     command = "ssh-keygen -y -f ${var.key_path} > ${var.key_path}.pub"
#   }

#   triggers = {
#     private_key = var.key_path
#   }
# }

# resource "aws_key_pair" "existing_key" {
#   key_name   = "existing_key"
#   public_key = file("${var.key_path}.pub")

#   depends_on = [null_resource.generate_public_key]
# }

resource "aws_ssm_parameter" "bastion_key_private" {
  name        = "/my-app/bastion_key_private"  # Give a descriptive name for the parameter
  description = "Private SSH key for Bastion host"
  type        = "SecureString"
  value       = tls_private_key.bastion_key.private_key_pem  # Store the private key
}
