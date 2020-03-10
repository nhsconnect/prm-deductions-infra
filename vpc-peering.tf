# VPC peering connection deductions-core  <->  deductions-private
resource "aws_vpc_peering_connection" "core_private" {
  peer_vpc_id = local.deductions_private_vpc_id
  vpc_id = local.deductions_core_vpc_id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "${var.environment}-deductions-core-private-peering"
  }
}

resource "aws_route" "core_to_private" {
  route_table_id            = local.deductions_core_private_subnets_route_table_id
  destination_cidr_block    = var.deductions_private_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.core_private.id
}

resource "aws_route" "private_private_to_core" {
  route_table_id            = local.deductions_private_private_subnets_route_table_id
  destination_cidr_block    = var.deductions_core_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.core_private.id
}

resource "aws_route" "private_public_to_core" {
  route_table_id            = local.deductions_private_public_subnets_route_table_id
  destination_cidr_block    = var.deductions_core_cidr
  vpc_peering_connection_id = aws_vpc_peering_connection.core_private.id
}
