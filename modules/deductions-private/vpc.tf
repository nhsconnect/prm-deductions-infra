module "vpc" {
    source                  = "terraform-aws-modules/vpc/aws"

    name                    = "${var.environment}-${var.component_name}-vpc"
    cidr                    = var.cidr

    azs                     = var.azs
    private_subnets         = var.private_subnets
    public_subnets          = var.public_subnets

    enable_vpn_gateway      = false

    enable_nat_gateway      = true
    single_nat_gateway      = true
    one_nat_gateway_per_az  = false
    enable_dns_support      = true
    enable_dns_hostnames    = true

    tags = {
        Terraform = "true"
        Environment = var.environment
        Deductions-VPC = var.component_name
    }
}

resource "aws_ssm_parameter" "private_rtb" {
    name = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/tf/deductions_private/private_rtb"
    type = "String"
    value = module.vpc.private_route_table_ids[0]

    tags = {
        Terraform = "true"
        Environment = var.environment
        Deductions-VPC = var.component_name
    }
}

resource "aws_ssm_parameter" "public_rtb" {
    name = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/tf/deductions_private/public_rtb"
    type = "String"
    value = module.vpc.public_route_table_ids[0]

    tags = {
        Terraform = "true"
        Environment = var.environment
        Deductions-VPC = var.component_name
    }
}
