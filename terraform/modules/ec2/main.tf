data "aws_ami" "latest_packer" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }
}

resource "aws_key_pair" "bastion_key" {
  key_name   = "bastion_key"
  public_key = tls_public_key.bastion_key.public_key_openssh
}

resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.latest_packer.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = aws_key_pair.bastion_key.key_name
  vpc_security_group_ids = var.security_groups

  tags = {
    Name = "bastion"
  }
}

resource "aws_instance" "server" {
  count                  = var.instance_count
  ami                    = data.aws_ami.latest_packer.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = [var.key_name, aws_key_pair.bastion_key.key_name]
  vpc_security_group_ids = var.security_groups

  tags = {
    Name = "server-${var.os_name}"
    OS   = var.os_name
  }
}