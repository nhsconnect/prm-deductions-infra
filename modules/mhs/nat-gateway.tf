resource "aws_nat_gateway" "internet" {
  allocation_id = aws_eip.nat_public_ip.id
  subnet_id     = aws_subnet.mhs_public.id

  tags = {
    Name = "${var.environment}-${var.cluster_name}-mhs-nat-gateway"
    Environment = var.environment
    CreatedBy = var.repo_name
  }
}

resource "aws_eip" "nat_public_ip" {
  tags = {
    Name = "${var.environment}-${var.cluster_name}-mhs-nat-public-ip"
  }
}