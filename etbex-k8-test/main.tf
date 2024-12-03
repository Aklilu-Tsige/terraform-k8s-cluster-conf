# Update your root main.tf
provider "aws" {
  region = var.region
}

module "keypair" {
  source = "./modules/keypair"

  environment = var.environment
}

module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  region               = var.region
  environment          = var.environment
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

module "security" {
  source = "./modules/security"

  vpc_id       = module.vpc.vpc_id
  vpc_cidr     = var.vpc_cidr
  trusted_ips  = var.trusted_ips
  environment  = var.environment
}

module "compute" {
  source = "./modules/compute"

  vpc_id               = module.vpc.vpc_id
  public_subnet_ids    = module.vpc.public_subnet_ids
  private_subnet_ids   = module.vpc.private_subnet_ids
  master_sg_id         = module.security.master_sg_id
  worker_sg_id         = module.security.worker_sg_id
  instance_type_master = var.instance_type_master
  instance_type_worker = var.instance_type_worker
  worker_count         = var.worker_count
  environment          = var.environment
  key_name            = module.keypair.key_name
}