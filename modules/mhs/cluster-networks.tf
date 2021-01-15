locals {
  repo_cidr_block = cidrsubnets(var.mhs_vpc_cidr_block, 1, 1)[0]
  test_harness_cidr_block = cidrsubnets(var.mhs_vpc_cidr_block, 1, 1)[1]

  repo_mhs_private_cidr_blocks = cidrsubnets(var.deploy_mhs_test_harness ? local.repo_cidr_block : var.mhs_vpc_cidr_block, 2, 2, 2)
  repo_internet_private_cidr_block = cidrsubnets(var.deploy_mhs_test_harness ? local.repo_cidr_block : var.mhs_vpc_cidr_block, 2, 2, 2, 4, 4)[3]

  mhs_public_cidr_block = cidrsubnets(var.deploy_mhs_test_harness ? local.repo_cidr_block : var.mhs_vpc_cidr_block, 2, 2, 2, 4, 4)[4]

  test_harness_mhs_private_cidr_blocks = cidrsubnets(local.test_harness_cidr_block, 2, 2, 2)
  test_harness_internet_private_cidr_block = cidrsubnets(local.test_harness_cidr_block, 2, 2, 2, 4, 4)[3]
//  in dev environment the following subnets are created: [
// repo_mhs_private_subnets:     "10.34.0.0/19",
//                               "10.34.32.0/19",
//                               "10.34.64.0/19",
// repo_internet_private_subnet: "10.34.96.0/21",
// mhs_public_subnet:            "10.34.104.0/21",
//]

  // in test environment the following subnets are created : >  cidrsubnets("10.239.68.128/25", 2, 2, 2, 4, 4)
  //[
  // repo_mhs_private_subnets         "10.239.68.128/27",
  //                                  "10.239.68.160/27",
  //                                  "10.239.68.192/27",
  //  repo_internet_private_subnet:   "10.239.68.224/29",
  //  mhs_public_subnet:              "10.239.68.232/29",
  //]
}

module "repo" {
  source    = "./cluster-network"
  environment    = var.environment
  repo_name = var.repo_name
  mhs_vpc_id = local.mhs_vpc_id
  cluster_name = "repo"
  deductions_private_cidr = var.deductions_private_cidr
  deductions_private_vpc_peering_connection_id = var.deductions_private_vpc_peering_connection_id
  deploy_opentest = var.deploy_opentest
  mhs_nat_gateway_id = aws_nat_gateway.internet.id
  mhs_subnets = local.repo_mhs_private_cidr_blocks
  opentest_cidr_block = local.repo_internet_private_cidr_block
}

module "test-harness" {
  source    = "./cluster-network"
  environment    = var.environment
  repo_name = var.repo_name
  mhs_vpc_id = local.mhs_vpc_id
  cluster_name = "test-harness"
  count = var.deploy_mhs_test_harness ? 1 : 0
  deductions_private_cidr = var.deductions_private_cidr
  deductions_private_vpc_peering_connection_id = var.deductions_private_vpc_peering_connection_id
  deploy_opentest = var.deploy_opentest
  mhs_nat_gateway_id = aws_nat_gateway.internet.id
  mhs_subnets = local.test_harness_mhs_private_cidr_blocks
  opentest_cidr_block = local.test_harness_internet_private_cidr_block
}