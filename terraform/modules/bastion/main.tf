data "aws_ami" "latest_packer" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }
}

# data "aws_ssm_parameter" "bastion_key_private" {
#   name = "/my-app/bastion_key_private"
#   with_decryption = true  # Decrypt the private key securely
# }

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.latest_packer.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = var.security_groups

  tags = {
    Name = "bastion"
  }

    # User Data to copy the private key directly to the bastion instance
  user_data = <<-EOF
              #!/bin/bash
              # Create the .ssh directory if it doesn't exist
              mkdir -p /home/ubuntu/.ssh
              # Copy the private key from Terraform into the bastion host
              echo "${var.bastion_key_private}" > /home/ubuntu/.ssh/bastion_key.pem
              # Secure the private key by setting the correct permissions
              chmod 600 /home/ubuntu/.ssh/bastion_key.pem
              chown ubuntu:ubuntu /home/ubuntu/.ssh/bastion_key.pem

              # Enable SSH Agent Forwarding by modifying sshd_config
              echo "AllowAgentForwarding yes" >> /etc/ssh/sshd_config
              systemctl restart sshd
              EOF
}
