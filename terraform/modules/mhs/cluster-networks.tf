module "cluster" {
  source    = "./cluster-network"
  providers = {
    aws = aws
    aws.ci = aws.ci
  }
  environment    = var.environment
  repo_name = var.repo_name
  mhs_vpc_id = local.mhs_vpc_id
  cluster_name = var.cluster_name
  deductions_private_cidr = var.deductions_private_cidr
  deductions_private_vpc_peering_connection_id = aws_vpc_peering_connection.private_mhs.id
  deploy_opentest = var.deploy_opentest
  mhs_nat_gateway_id = aws_nat_gateway.internet.*.id
  mhs_subnets = var.mhs_private_cidr_blocks
  opentest_cidr_block = var.internet_private_cidr_block
  mhs_vpc_cidr_block = var.mhs_vpc_cidr_block
  dns_hscn_forward_server_1 = var.dns_hscn_forward_server_1
  dns_hscn_forward_server_2 = var.dns_hscn_forward_server_2
  dns_forward_zone          = var.dns_forward_zone
  region = var.region
  unbound_image_version = var.unbound_image_version
  spine_cidr_block = var.spine_cidr_block
  gocd_cidr = var.gocd_cidr
  gocd_environment = "prod"
  deploy_cross_account_vpc_peering = var.deploy_cross_account_vpc_peering
}