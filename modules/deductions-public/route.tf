resource "aws_route_table" "public_az1_rtb" {
  vpc_id = "${aws_vpc.main-vpc.id}"

  route {
    gateway_id = "${aws_internet_gateway.igw.id}"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "${var.environment}-${var.component_name}-vpc-public-az1-rtb"
  }
}

resource "aws_route_table" "public_az2_rtb" {
  vpc_id = "${aws_vpc.main-vpc.id}"

  route {
    gateway_id = "${aws_internet_gateway.igw.id}"
    cidr_block = "0.0.0.0/0"
  }

  tags = {
    Name = "${var.environment}-${var.component_name}-vpc-public-az2-rtb"
  }
}

resource "aws_route_table" "private-az1-rtb" {
  vpc_id = "${aws_vpc.main-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.public-1-natg.id}"
  }

  tags = {
    Name = "${var.environment}-${var.component_name}-vpc-private-az1-rtb"
  }
}

resource "aws_route_table" "private-az2-rtb" {
  vpc_id = "${aws_vpc.main-vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.public-1-natg.id}"
  }

  tags = {
    Name = "${var.environment}-${var.component_name}-vpc-private-az2-rtb"
  }
}

resource "aws_route_table_association" "public-az1-rta" {
  subnet_id      = "${aws_subnet.public-subnets[0].id}"
  route_table_id = "${aws_route_table.public_az1_rtb.id}"
}

resource "aws_route_table_association" "public-az2-rta" {
  subnet_id      = "${aws_subnet.public-subnets[1].id}"
  route_table_id = "${aws_route_table.public_az2_rtb.id}"
}

resource "aws_route_table_association" "private-az1-rta" {
  subnet_id      = "${aws_subnet.private-subnets[0].id}"
  route_table_id = "${aws_route_table.private-az1-rtb.id}"
}

resource "aws_route_table_association" "private-az2-rta" {
  subnet_id      = "${aws_subnet.private-subnets[1].id}"
  route_table_id = "${aws_route_table.private-az2-rtb.id}"
}