module "repo" {
  source    = "./cluster-network"
  environment    = var.environment
  mhs_vpc_cidr_block = var.mhs_vpc_cidr_block
  repo_name = var.repo_name
  cidr_newbits= var.cidr_newbits
  mhs_vpc_id = local.mhs_vpc_id
  cluster_name = "repo"
  cidr_delta = 0
  deductions_private_cidr = var.deductions_private_cidr
  deductions_private_vpc_peering_connection_id = var.deductions_private_vpc_peering_connection_id
}

module "test-harness" {
  source    = "./cluster-network"
  environment    = var.environment
  mhs_vpc_cidr_block = var.mhs_vpc_cidr_block
  repo_name = var.repo_name
  cidr_newbits= var.cidr_newbits
  mhs_vpc_id = local.mhs_vpc_id
  cluster_name = "test-harness"
  count = var.deploy_mhs_test_harness ? 1 : 0
  cidr_delta = 15
  deductions_private_cidr = var.deductions_private_cidr
  deductions_private_vpc_peering_connection_id = var.deductions_private_vpc_peering_connection_id
}