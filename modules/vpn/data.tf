data "aws_ssm_parameter" "inbound_ips" {
    name = "/NHS/dev-${data.aws_caller_identity.current.account_id}/tf/inbound_ips"
}

data "aws_ssm_parameter" "public_zone_id" {
    name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/root_zone_id"
}

data "aws_route53_zone" "public_zone" {
  zone_id         = data.aws_ssm_parameter.public_zone_id.value
  private_zone    = false
}

data "aws_caller_identity" "current" {}

data "aws_route_table" "public-subnet" {
  subnet_id = var.public_subnet_id
}

data "aws_subnet" "public-subnet" {
  id = var.public_subnet_id
}

locals {
  public_subnet_cidr = data.aws_subnet.public-subnet.cidr_block
}
