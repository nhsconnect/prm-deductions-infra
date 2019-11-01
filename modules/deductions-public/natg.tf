resource "aws_nat_gateway" "public-1-natg" {
  allocation_id = "${aws_eip.natg-eip.id}"
  subnet_id     = "${aws_subnet.public-subnets[0].id}"

  tags = {
    Name = "${var.environment}-${var.component_name}_public-1-natg"
  }
}

resource "aws_eip" "natg-eip" {
  vpc      = true
}