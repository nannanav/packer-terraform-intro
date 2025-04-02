provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source         = "./modules/vpc"
  vpc_cidr       = "10.0.0.0/16"
  public_subnet  = ["10.0.1.0/24"]
  private_subnet = ["10.0.2.0/24"]
}

module "key_pair" {
  source   = "./modules/keys"
  key_path = var.key_path
}

module "ubuntu-ansible-bastion" {
  source         = "./modules/bastion"
  ami_name_pattern  = "custom-ubuntu-ansible-*"
  instance_count = 1
  subnet_id      = module.vpc.public_subnet_ids[0]
  instance_type  = "t2.micro"
  key_name       = module.key_pair.existing_key
  security_groups = [module.vpc.bastion_sg_id]
  os_name           = "ubuntu"
  bastion_key_private = module.key_pair.bastion_key.private_key_pem
}

module "amazon_linux" {
  source         = "./modules/ec2"
  ami_name_pattern  = "custom-amazon-linux-docker-*"
  instance_count = 3
  subnet_id      = module.vpc.private_subnet_ids[0]
  instance_type  = "t2.micro"
  key_name       = module.key_pair.bastion_key.key_name
  security_groups = [module.vpc.private_sg_id]
  os_name           = "amazon"
}

module "ubuntu" {
  source         = "./modules/ec2"
  ami_name_pattern  = "custom-ubuntu-docker-*"
  instance_count = 3
  subnet_id      = module.vpc.private_subnet_ids[0]
  instance_type  = "t2.micro"
  key_name       = module.key_pair.bastion_key.key_name
  security_groups = [module.vpc.private_sg_id]
  os_name           = "ubuntu"
}

# output "ec2_private_ips" {
#   value = concat(
#     module.amazon_linux.instance_private_ips,
#     module.ubuntu.instance_private_ips
#   )
# }

output ubuntu_private_ips {
  value = module.ubuntu.instance_private_ips
}

output al_private_ips {
  value = module.amazon_linux.instance_private_ips
}

output "bastion_ip" {
  value = module.ubuntu-ansible-bastion.bastion_ip
}
