module "vpc" {
  #source = "../vpc"
  source = "git::https://github.com/ShivanathBabu/vpc.git?ref=main"
  project = var.project
  environment = var.environment
    public_subnet_cidrs = var.public_subnet_cidr
    private_subnet_cidrs = var.private_subnet_cidr
    database_subnet_cidrs = var.database_subnet_cidr

    is_peering_required = true
}
/* 
output "vpc_ids" {
  value = module.vpc.public_subnet_ids
} */