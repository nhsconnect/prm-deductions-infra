# These resources are only needed to deploy GoCD in the MHS network

module "gocd" {
    source = "git::https://github.com/nhsconnect/prm-gocd-infra.git//remote-agents-module"
    environment = "prod"
    region = "${var.region}"
    az = var.azs[0]
    vpc_id = module.vpc.vpc_id
    subnet_id = module.vpc.public_subnets[0]
    agent_resources = "${var.environment},deductions-private"
    allocate_public_ip = true
    agent_count = 1
}

data "aws_ssm_parameter" "gocd_zone_id" {
  name = "/repo/${var.gocd_environment}/output/prm-gocd-infra/gocd-route53-zone-id"
}

locals {
  gocd_zone_id = data.aws_ssm_parameter.gocd_zone_id.value
}


data "aws_ssm_parameter" "route_table_id" {
  name = "/repo/${var.gocd_environment}/output/prm-gocd-infra/gocd-route-table-id"
}

# Allow DNS resolution of the domain names defined in gocd VPC in deductions_private vpc
resource "aws_route53_zone_association" "deductions_private_hosted_zone_gocd_vpc_association" {
  zone_id = local.gocd_zone_id
  vpc_id = module.vpc.vpc_id
}
