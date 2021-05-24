resource "aws_route_table" "mhs" {
  vpc_id = var.mhs_vpc_id
  tags = {
    Name = "${var.environment}-${var.cluster_name}-mhs-route-table"
    Environment = var.environment
    CreatedBy = var.repo_name
  }
}

resource "aws_route" "deductions_private" {
  route_table_id            = aws_route_table.mhs.id
  destination_cidr_block    = var.deductions_private_cidr
  vpc_peering_connection_id = var.deductions_private_vpc_peering_connection_id
}

resource "aws_route" "spine" {
  count = var.deploy_opentest ? 1 : 0
  route_table_id            = aws_route_table.mhs.id
  destination_cidr_block    = var.spine_cidr_block
  instance_id = join(",", module.opentest.*.vpn_instance_id)
}

resource "aws_route" "spine_hscn" {
  count = var.deploy_opentest ? 0 : 1
  route_table_id            = aws_route_table.mhs.id
  destination_cidr_block    = "0.0.0.0/0"
  gateway_id = var.hscn_gateway_id
}

resource "aws_vpc_peering_connection" "mhs_to_gocd" {
  peer_vpc_id = data.aws_ssm_parameter.gocd_vpc.value
  vpc_id = var.mhs_vpc_id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "${var.environment}-mhs-${var.cluster_name}-gocd-peering"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_route" "mhs_to_gocd" {
  route_table_id            = aws_route_table.mhs.id
  destination_cidr_block    = var.gocd_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.mhs_to_gocd.id
}

resource "aws_route" "gocd_to_mhs" {
  route_table_id            = data.aws_ssm_parameter.gocd_route_table_id.value
  destination_cidr_block    = var.mhs_vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.mhs_to_gocd.id
}

data "aws_ssm_parameter" "gocd_vpc" {
  name = "/repo/prod/output/prm-gocd-infra/gocd-vpc-id"
}

data "aws_ssm_parameter" "gocd_route_table_id" {
  name = "/repo/${var.gocd_environment}/output/prm-gocd-infra/gocd-route-table-id"
}