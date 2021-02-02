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