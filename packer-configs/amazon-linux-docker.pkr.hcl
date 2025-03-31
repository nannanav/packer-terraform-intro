source "amazon-ebs" "amazon-linux-docker" {
  ami_name      = "custom-amazon-linux-docker-{{timestamp}}"
  instance_type = "t2.micro"
  region        = var.aws_region
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    owners      = ["amazon"]
    most_recent = true
  }
  ssh_username  = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.amazon-linux-docker"]

  provisioner "shell" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y docker",
      "sudo systemctl enable docker",
      "sudo systemctl start docker",
      "sudo usermod -aG docker ec2-user",
    ]
  }
}
