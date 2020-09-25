data "aws_ssm_parameter" "agent_ips" {
    name = "/repo/prod/prm-deductions-base-infra/output/gocd-agent-ips"
}

data "aws_ssm_parameter" "public_zone_id" {
    name = "/repo/prm-deductions-base-infra/output/root-zone-id"
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

data "aws_ssm_parameter" "dynamic_vpn_sg" {
  name = "/repo/${var.environment}/prm-deductions-base-infra/output/vpn-sg"
}

locals {
  public_subnet_cidr = data.aws_subnet.public-subnet.cidr_block

  agent_cidrs = [
    for ip in split(",", data.aws_ssm_parameter.agent_ips.value):
      "${ip}/32"
  ]
  # This local should be the only source of truth on what IPs are allowed to connect from the Internet
  allowed_public_ips = local.agent_cidrs

  dynamic_vpn_sg = data.aws_ssm_parameter.dynamic_vpn_sg.value
}
