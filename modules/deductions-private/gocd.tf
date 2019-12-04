# These resources are only needed to deploy GoCD in the MHS network

module "gocd" {
    source = "git::https://github.com/nhsconnect/prm-gocd-infra.git//remote-agents-module"
    environment = "prod"
    region = "${var.region}"
    az = "eu-west-2a"
    vpc_id = module.vpc.vpc_id
    subnet_id = module.vpc.public_subnets[0]
    agent_resources = "${var.environment},deductions-private"
    allocate_public_ip = true
    agent_count = 1
}

data "aws_ssm_parameter" "gocd_vpc" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/gocd-prod/vpc_id"
}

data "aws_ssm_parameter" "gocd_zone_id" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/gocd-prod/route53_zone_id"
}

data "aws_ssm_parameter" "gocd_cidr_block" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/gocd-prod/cidr_block"
}

locals {
  gocd_vpc = data.aws_ssm_parameter.gocd_vpc.value
  gocd_zone_id = data.aws_ssm_parameter.gocd_zone_id.value
  gocd_cidr_block = data.aws_ssm_parameter.gocd_cidr_block.value
  public_subnet_route_table = module.vpc.public_route_table_ids[0]
}

# VPC peering connection with GoCD server
resource "aws_vpc_peering_connection" "gocd_peering_connection" {
  peer_vpc_id = local.gocd_vpc
  vpc_id = module.vpc.vpc_id
  auto_accept = true

  accepter {
    allow_remote_vpc_dns_resolution = true
  }

  requester {
    allow_remote_vpc_dns_resolution = true
  }

  tags = {
    Name = "deductions-private-gocd-peering-connection"
  }
}

data "aws_ssm_parameter" "route_table_id" {
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/gocd-prod/route_table_id"
}

# Add a route to the deductions-private VPC in the gocd VPC route table
resource "aws_route" "gocd_to_deductions_private_route" {
  route_table_id = data.aws_ssm_parameter.route_table_id.value
  destination_cidr_block = "10.20.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.gocd_peering_connection.id
}

# Add a route to the gocd VPC in the deductions_private VPC route table
resource "aws_route" "deductions_private_to_gocd_route" {
  route_table_id = local.public_subnet_route_table
  destination_cidr_block = local.gocd_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.gocd_peering_connection.id
}

# Allow DNS resolution of the domain names defined in gocd VPC in deductions_private vpc
resource "aws_route53_zone_association" "deductions_private_hosted_zone_gocd_vpc_association" {
  zone_id = local.gocd_zone_id
  vpc_id = module.vpc.vpc_id
}
