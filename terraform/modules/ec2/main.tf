data "aws_ami" "latest_packer" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }
}

resource "aws_instance" "server" {
  count                  = var.instance_count
  ami                    = data.aws_ami.latest_packer.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  vpc_security_group_ids = var.security_groups

  tags = {
    Name = "server-${var.os_name}"
    OS   = var.os_name
  }
}
