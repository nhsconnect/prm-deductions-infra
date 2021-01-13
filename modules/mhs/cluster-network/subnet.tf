# Create a private subnet in each availability zone in the region.
resource "aws_subnet" "mhs_subnet" {
  count = 3

  vpc_id = var.mhs_vpc_id
  availability_zone = data.aws_availability_zones.all.names[count.index]

  # Generates a CIDR block with a different prefix within the VPC's CIDR block for each subnet being created.
  # E.g if the VPC's CIDR block is 10.0.0.0/16, this generates subnets that have CIDR blocks 10.0.0.0/24, 10.0.1.0/24,
  # etc.
  # see https://www.terraform.io/docs/configuration/functions/cidrsubnet.html
  cidr_block = cidrsubnet(var.mhs_vpc_cidr_block, var.cidr_newbits, count.index + var.cidr_delta)

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.environment}-${var.cluster_name}-mhs-subnet-${data.aws_availability_zones.all.names[count.index]}"
    Environment = var.environment
    CreatedBy = var.repo_name
  }
}