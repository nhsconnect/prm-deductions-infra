locals {
  mhs_vpc_id = aws_vpc.mhs_vpc.id
  mhs_vpc_cidr_block = aws_vpc.mhs_vpc.cidr_block
  mhs_vpc_route_table_id = aws_vpc.mhs_vpc.main_route_table_id
}

# The MHS VPC that contains the running MHS
resource "aws_vpc" "mhs_vpc" {
  # Note that this cidr block must not overlap with the cidr blocks of the VPCs
  # that the MHS VPC is peered with.
  cidr_block = var.mhs_vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "${var.environment}-${var.cluster_name}-mhs-vpc"
    Environment = var.environment
    CreatedBy = var.repo_name
  }
}

resource "aws_vpc_ipv4_cidr_block_association" "secondary_cidr" {
  count      = var.mhs_vpc_additional_cidr_block == "" ? 0 : 1
  vpc_id     = aws_vpc.mhs_vpc.id
  cidr_block = var.mhs_vpc_additional_cidr_block
}