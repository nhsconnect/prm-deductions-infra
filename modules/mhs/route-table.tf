resource "aws_route_table" "public" {
  vpc_id = aws_vpc.mhs_vpc.id
  tags = {
    Name = "${var.environment}-public-route-table"
    Environment = var.environment
    CreatedBy = var.repo_name
  }
}

resource "aws_route" "public_internet" {
  route_table_id = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id = aws_internet_gateway.internet.id
}