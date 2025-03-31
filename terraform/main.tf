provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source         = "./modules/vpc"
  vpc_cidr       = "10.0.0.0/16"
  public_subnet  = ["10.0.1.0/24"]
  private_subnet = ["10.0.2.0/24"]
}

module "ubuntu-ansible-bastion" {
  source         = "./modules/ec2"
  ami_name_pattern  = "custom-ubuntu-ansible-*"
  instance_count = 1
  subnet_id      = module.vpc.public_subnet_ids[0]
  instance_type  = "t2.micro"
  key_name       = var.key_name
  security_groups = [module.vpc.bastion_sg_id]
  os_name           = "ubuntu"
}

module "amazon_linux" {
  source         = "./modules/ec2"
  ami_name_pattern  = "custom-amazon-linux-docker-*"
  instance_count = 3
  subnet_id      = module.vpc.private_subnet_ids[0]
  instance_type  = "t2.micro"
  key_name       = var.key_name
  security_groups = [module.vpc.private_sg_id]
  os_name           = "amazon"
}

module "ubuntu" {
  source         = "./modules/ec2"
  ami_name_pattern  = "custom-ubuntu-docker-*"
  instance_count = 3
  subnet_id      = module.vpc.private_subnet_ids[0]
  instance_type  = "t2.micro"
  key_name       = var.key_name
  security_groups = [module.vpc.private_sg_id]
  os_name           = "ubuntu"
}
