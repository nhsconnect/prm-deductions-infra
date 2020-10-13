provider "aws" {
  profile = "default"
  version = "~> 2.50"
  region  = var.region
}

terraform {
  backend "s3" {
    bucket  = "prm-deductions-terraform-state"
    key     = "infra/terraform.tfstate"
    region  = "eu-west-2"
    encrypt = true
  }
}

# module "deductions-public" {
#     source              = "./modules/deductions-public/"
#     environment         = var.environment
#     cidr                = var.deductions_public_cidr
#     component_name      = var.deductions_public_component_name

#     public_subnets      = var.deductions_public_public_subnets
#     private_subnets     = var.deductions_public_private_subnets
#     azs                 = var.deductions_public_azs

#     allowed_public_ips  = local.allowed_public_ips

#     private_zone_id     = aws_route53_zone.private.zone_id
# }

module "deductions-private" {
  source         = "./modules/deductions-private/"
  environment    = var.environment
  cidr           = var.deductions_private_cidr
  component_name = var.deductions_private_component_name

  public_subnets   = var.deductions_private_public_subnets
  private_subnets  = var.deductions_private_private_subnets
  database_subnets = var.deductions_private_database_subnets
  azs              = var.deductions_private_azs
  private_zone_id  = aws_route53_zone.private.zone_id

  allowed_public_ips = local.allowed_public_ips

  gocd_cidr            = var.gocd_cidr
  deductions_core_cidr = var.deductions_core_cidr
  mhs_cidr             = var.mhs_cidr

  broker_name                    = var.broker_name
  deployment_mode                = var.deployment_mode
  mq_deployment_mode             = var.mq_deployment_mode
  engine_type                    = var.engine_type
  engine_version                 = var.engine_version
  host_instance_type             = var.host_instance_type
  auto_minor_version_upgrade     = var.auto_minor_version_upgrade
  apply_immediately              = var.apply_immediately
  general_log                    = var.general_log
  audit_log                      = var.audit_log
  maintenance_day_of_week        = var.maintenance_day_of_week
  maintenance_time_of_day        = var.maintenance_time_of_day
  maintenance_time_zone          = var.maintenance_time_zone
  mq_allow_public_console_access = var.mq_allow_public_console_access
  vpn_client_subnet              = var.deductions_private_vpn_client_subnet

  state_db_allocated_storage = var.state_db_allocated_storage
  state_db_engine_version    = var.state_db_engine_version
  state_db_instance_class    = var.state_db_instance_class
}

# module "vpn" {
#     source              = "./modules/vpn/"
#     region              = var.region
#     vpc_id              = module.deductions-private.vpc_id
#     availability_zone   = var.deductions_private_azs[0]
#     public_subnet_id    = module.deductions-private.public_subnet_id
#     environment         = var.environment
#     my_ip               = var.my_ip
# }

module "deductions-core" {
  source         = "./modules/deductions-core/"
  environment    = var.environment
  component_name = var.deductions_core_component_name

  cidr             = var.deductions_core_cidr
  public_subnets   = var.deductions_core_public_subnets
  private_subnets  = var.deductions_core_private_subnets
  database_subnets = var.deductions_core_database_subnets
  azs              = var.deductions_core_azs

  allowed_cidr       = var.deductions_private_cidr
  private_zone_id    = aws_route53_zone.private.zone_id
  allowed_public_ips = local.allowed_public_ips
}

module "utils" {
  source      = "./modules/utils"
  region      = var.region
  environment = var.environment
}

locals {
  deductions_core_vpc_id    = module.deductions-core.vpc_id
  deductions_private_vpc_id = module.deductions-private.vpc_id

  deductions_core_private_subnets_route_table_id    = module.deductions-core.private_subnets_route_table_id
  deductions_private_private_subnets_route_table_id = module.deductions-private.private_subnets_route_table_id
  deductions_private_public_subnets_route_table_id  = module.deductions-private.public_subnets_route_table_id
}
