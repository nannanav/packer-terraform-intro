provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source         = "./modules/vpc"
  vpc_cidr       = "10.0.0.0/16"
  public_subnet  = ["10.0.1.0/24"]
  private_subnet = ["10.0.2.0/24"]
}

module "bastion" {
  source         = "./modules/ec2"
  instance_count = 1
  subnet_id      = module.vpc.public_subnet_ids[0]
  instance_type  = "t2.micro"
  key_name       = var.key_name
  security_groups = [module.vpc.bastion_sg_id]
}

module "private_ec2" {
  source         = "./modules/ec2"
  instance_count = 6
  subnet_id      = module.vpc.private_subnet_ids[0]
  instance_type  = "t2.micro"
  key_name       = var.key_name
  security_groups = [module.vpc.private_sg_id]
}