provider "aws" {
  profile = "default"
  region  = var.region
}

provider "aws" {
  alias = "ci"
  region  = var.region
  assume_role {
    role_arn     = "arn:aws:iam::${var.common_account_id}:role/RepoAdmin"
    session_name = "common-dev-cross-account"
  }
}

terraform {
  backend "s3" {
    encrypt = true
  }
}

locals {
  first_half_mhs_cidr_block = cidrsubnets(var.mhs_vpc_cidr_block, 1, 1)[0]
  second_half_mhs_cidr_block = cidrsubnets(var.mhs_vpc_cidr_block, 1, 1)[1]
  repo_cidr_block = var.deploy_mhs_test_harness ? local.first_half_mhs_cidr_block : var.mhs_vpc_cidr_block

  repo_mhs_private_cidr_blocks = cidrsubnets(var.deploy_mhs_test_harness ? local.first_half_mhs_cidr_block : var.mhs_vpc_cidr_block, 2, 2, 2)
  repo_internet_private_cidr_block = cidrsubnets(var.deploy_mhs_test_harness ? local.first_half_mhs_cidr_block : var.mhs_vpc_cidr_block, 2, 2, 2, 3, 3)[3]
  repo_mhs_public_cidr_block = cidrsubnets(var.deploy_mhs_test_harness ? local.first_half_mhs_cidr_block : var.mhs_vpc_cidr_block, 2, 2, 2, 3, 3)[4]

  test_harness_mhs_private_cidr_blocks = cidrsubnets(local.second_half_mhs_cidr_block, 2, 2, 2)
  test_harness_internet_private_cidr_block = cidrsubnets(local.second_half_mhs_cidr_block, 2, 2, 2, 4, 4)[3]
  test_harness_mhs_public_cidr_block = cidrsubnets(local.second_half_mhs_cidr_block, 2, 2, 2, 4, 4)[4]
  //  in dev environment te following subnets are created: [
  // repo_mhs_private_subnets:     "10.34.0.0/19",
  //                               "10.34.32.0/19",
  //                               "10.34.64.0/19",
  // repo_internet_private_subnet: "10.34.96.0/20",
  // mhs_public_subnet:            "10.34.104.0/20",
  //]

  // in test environment the following subnets are created : >  cidrsubnets("10.239.68.128/25", 2, 2, 2, 4, 4)
  //[
  // repo_mhs_private_subnets         "10.239.68.128/27",
  //                                  "10.239.68.160/27",
  //                                  "10.239.68.192/27",
  //  repo_internet_private_subnet:   "10.239.68.224/28",
  //  mhs_public_subnet:              "10.239.68.232/28",
  //]
}

module "repo" {
  source    = "./modules/mhs/"
  providers = {
    aws = aws
    aws.ci = aws.ci
  }
  environment    = var.environment
  mhs_vpc_cidr_block = local.repo_cidr_block
  repo_name = var.repo_name
  cluster_name = "repo"
  deploy_opentest = var.deploy_opentest
  deploy_public_subnet = var.deploy_mhs_public_subnet
  deductions_private_cidr = var.deductions_private_cidr
  dns_hscn_forward_server_1 = var.dns_hscn_forward_server_1
  dns_hscn_forward_server_2 = var.dns_hscn_forward_server_2
  dns_forward_zone          = var.dns_forward_zone
  region = var.region
  unbound_image_version = var.unbound_image_version
  mhs_private_cidr_blocks = local.repo_mhs_private_cidr_blocks
  internet_private_cidr_block = local.repo_internet_private_cidr_block
  mhs_public_cidr_block = local.repo_mhs_public_cidr_block
  spine_cidr_block = var.spine_cidr_block
  deductions_private_vpc_id = local.deductions_private_vpc_id
  mhs_cluster_domain_name = var.repo_mhs_cluster_domain_name
  hscn_gateway_id = var.hscn_gateway_id
  gocd_cidr            = var.gocd_cidr
  deploy_cross_account_vpc_peering = var.deploy_cross_account_vpc_peering
  deploy_hscn = var.deploy_hscn
}

module "test-harness" {
  source    = "./modules/mhs/"
  providers = {
    aws = aws
    aws.ci = aws.ci
  }
  count = var.deploy_mhs_test_harness ? 1 : 0
  environment    = var.environment
  mhs_vpc_cidr_block = local.second_half_mhs_cidr_block
  repo_name = var.repo_name
  cluster_name = "test-harness"
  deploy_opentest = var.deploy_opentest
  deploy_public_subnet = var.deploy_mhs_public_subnet
  deductions_private_cidr = var.deductions_private_cidr
  dns_hscn_forward_server_1 = var.dns_hscn_forward_server_1
  dns_hscn_forward_server_2 = var.dns_hscn_forward_server_2
  dns_forward_zone          = var.dns_forward_zone
  region = var.region
  unbound_image_version = var.unbound_image_version
  mhs_private_cidr_blocks = local.test_harness_mhs_private_cidr_blocks
  internet_private_cidr_block = local.test_harness_internet_private_cidr_block
  mhs_public_cidr_block = local.test_harness_mhs_public_cidr_block
  spine_cidr_block = var.spine_cidr_block
  deductions_private_vpc_id = local.deductions_private_vpc_id
  mhs_cluster_domain_name = var.test_harness_mhs_cluster_domain_name
  hscn_gateway_id = var.hscn_gateway_id
  gocd_cidr            = var.gocd_cidr
  deploy_cross_account_vpc_peering = var.deploy_cross_account_vpc_peering
  deploy_hscn = var.deploy_hscn
}

module "deductions-private" {
  source         = "./modules/deductions-private/"
  providers = {
    aws = aws
    aws.ci = aws.ci
  }
  environment    = var.environment
  cidr           = var.deductions_private_cidr
  component_name = var.deductions_private_component_name

  public_subnets   = var.deductions_private_public_subnets
  private_subnets  = var.deductions_private_private_subnets
  database_subnets = var.deductions_private_database_subnets
  azs              = var.deductions_private_azs
  environment_private_zone  = aws_route53_zone.environment_private
  environment_public_zone = aws_route53_zone.environment_public

  gocd_cidr            = var.gocd_cidr
  deductions_core_cidr = var.deductions_core_cidr
  repo_mhs_vpc_cidr_block     = local.repo_cidr_block
  test_harness_mhs_vpc_cidr_block = var.deploy_mhs_test_harness ? local.second_half_mhs_cidr_block : ""
  deploy_mhs_test_harness = var.deploy_mhs_test_harness

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

  core_private_vpc_peering_connection_id = aws_vpc_peering_connection.core_private.id
  repo_mhs_vpc_peering_connection_id = module.repo.private_mhs_vpc_peering_id
  test_harness_mhs_vpc_peering_connection_id = join(",", module.test-harness.*.private_mhs_vpc_peering_id)
  deploy_cross_account_vpc_peering = var.deploy_cross_account_vpc_peering
}

module "deductions-core" {
  source         = "./modules/deductions-core/"
  providers = {
    aws = aws
    aws.ci = aws.ci
  }
  environment    = var.environment
  component_name = var.deductions_core_component_name

  cidr             = var.deductions_core_cidr
  deductions_private_cidr = var.deductions_private_cidr
  gocd_cidr        = var.gocd_cidr
  public_subnets   = var.deductions_core_public_subnets
  private_subnets  = var.deductions_core_private_subnets
  database_subnets = var.deductions_core_database_subnets
  azs              = var.deductions_core_azs
  core_private_vpc_peering_connection_id = aws_vpc_peering_connection.core_private.id
  gocd_environment = "prod"
  deploy_cross_account_vpc_peering = var.deploy_cross_account_vpc_peering
}

module "utils" {
  source      = "./modules/utils"
  region      = var.region
  environment = var.environment
}

locals {
  deductions_core_vpc_id    = module.deductions-core.vpc_id
  deductions_private_vpc_id = module.deductions-private.vpc_id
  repo_mhs_vpc_id = module.repo.vpc_id
  test_harness_mhs_vpc_id = join(",", module.test-harness.*.vpc_id)

  deductions_core_private_subnets_route_table_id    = module.deductions-core.private_subnets_route_table_id
  deductions_private_private_subnets_route_table_id = module.deductions-private.private_subnets_route_table_id
  deductions_private_public_subnets_route_table_id  = module.deductions-private.public_subnets_route_table_id
}
