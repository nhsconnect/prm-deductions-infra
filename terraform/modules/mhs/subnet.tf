resource "aws_subnet" "mhs_public" {
  count = var.deploy_public_subnet ? 1 : 0
  vpc_id = aws_vpc.mhs_vpc.id
  availability_zone = data.aws_availability_zones.all.names[0]
  cidr_block = var.mhs_public_cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-${var.cluster_name}-mhs-public-subnet-${data.aws_availability_zones.all.names[0]}"
    Environment = var.environment
    CreatedBy = var.repo_name
  }
}

resource "aws_route_table_association" "mhs_public" {
  count = var.deploy_public_subnet ? 1 : 0
  subnet_id      = aws_subnet.mhs_public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}