resource "aws_subnet" "public-subnets" {
  count = "${length(var.public_subnets)}"

  vpc_id                  = "${aws_vpc.main-vpc.id}"
  cidr_block              = element(concat(var.public_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.environment}-${var.component_name}-public-az${count.index}"
  }
}

resource "aws_subnet" "private-subnets" {
  count = "${length(var.public_subnets)}"

  vpc_id                  = "${aws_vpc.main-vpc.id}"
  cidr_block              = element(concat(var.private_subnets, [""]), count.index)
  availability_zone       = element(var.azs, count.index)

  tags = {
    Name = "${var.environment}-${var.component_name}-private-az${count.index}"
  }
}