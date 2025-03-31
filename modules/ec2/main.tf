data "aws_ami" "latest_packer" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["node-*"]
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
    Name = "node-${count.index + 1}"  # Creates unique names like node-1, node-2, etc.
  }
}
