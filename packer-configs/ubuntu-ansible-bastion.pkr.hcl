source "amazon-ebs" "ubuntu-ansible-bastion" {
  ami_name      = "custom-ubuntu-ansible-{{timestamp}}"
  instance_type = "t2.micro"
  region        = var.aws_region
  source_ami_filter {
    filters = {
      name                = "ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["099720109477"] # Canonical's AWS account ID
    most_recent = true
  }
  ssh_username  = "ubuntu"
}

build {
  sources = ["source.amazon-ebs.ubuntu-ansible-bastion"]

  provisioner "shell" {
    inline = [
      "export DEBIAN_FRONTEND=noninteractive",
      "sleep 30",
      "sudo apt-get update -y",
      "sudo apt-get install -y docker.io openssh-server ansible",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ubuntu",
    ]
  }
}
