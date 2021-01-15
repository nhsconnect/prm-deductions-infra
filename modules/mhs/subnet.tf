resource "aws_subnet" "mhs_public" {
  vpc_id = aws_vpc.mhs_vpc.id
  availability_zone = data.aws_availability_zones.all.names[0]
  cidr_block = local.mhs_public_cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-mhs-public-subnet-${data.aws_availability_zones.all.names[0]}"
    Environment = var.environment
    CreatedBy = var.repo_name
  }
}

resource "aws_route_table_association" "mhs_public" {
  subnet_id      = aws_subnet.mhs_public.id
  route_table_id = aws_route_table.public.id
}