resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

// We do not use the default VPC SG. This resource removes all ingress/egress rules from it for security reasons.
resource "aws_default_security_group" "default" {
  vpc_id = aws_default_vpc.default.id
}