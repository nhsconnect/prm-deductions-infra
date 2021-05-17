module "vpc" {
    source                  = "terraform-aws-modules/vpc/aws"

    name                    = "${var.environment}-${var.component_name}-vpc"
    cidr                    = var.cidr

    azs                     = var.azs
    private_subnets         = var.private_subnets
    public_subnets          = var.public_subnets
    database_subnets        = var.database_subnets

    enable_vpn_gateway      = false

    enable_nat_gateway      = true
    single_nat_gateway      = true
    one_nat_gateway_per_az  = false
    enable_dns_support      = true
    enable_dns_hostnames    = true

    tags = {
        CreatedBy   = var.repo_name
        Environment = var.environment
    }
}

resource "aws_route" "private_private_to_core" {
    route_table_id            = module.vpc.private_route_table_ids[0]
    destination_cidr_block    = var.deductions_core_cidr
    vpc_peering_connection_id = var.core_private_vpc_peering_connection_id
}

resource "aws_route" "private_public_to_core" {
    route_table_id            = module.vpc.public_route_table_ids[0]
    destination_cidr_block    = var.deductions_core_cidr
    vpc_peering_connection_id = var.core_private_vpc_peering_connection_id
}

resource "aws_route" "private_private_to_mhs_repo" {
    route_table_id            = module.vpc.private_route_table_ids[0]
    destination_cidr_block    = var.repo_mhs_vpc_cidr_block
    vpc_peering_connection_id = var.repo_mhs_vpc_peering_connection_id
}

resource "aws_route" "private_private_to_mhs_test_harness" {
    count                     = var.deploy_mhs_test_harness ? 1 : 0
    route_table_id            = module.vpc.private_route_table_ids[0]
    destination_cidr_block    = var.test_harness_mhs_vpc_cidr_block
    vpc_peering_connection_id = var.test_harness_mhs_vpc_peering_connection_id
}

resource "aws_route" "private_public_to_mhs_repo" {
    route_table_id            = module.vpc.public_route_table_ids[0]
    destination_cidr_block    = var.repo_mhs_vpc_cidr_block
    vpc_peering_connection_id = var.repo_mhs_vpc_peering_connection_id
}

resource "aws_route" "private_public_to_mhs_test_harness" {
    count                     = var.deploy_mhs_test_harness ? 1 : 0
    route_table_id            = module.vpc.public_route_table_ids[0]
    destination_cidr_block    = var.test_harness_mhs_vpc_cidr_block
    vpc_peering_connection_id = var.test_harness_mhs_vpc_peering_connection_id
}

resource "aws_ec2_transit_gateway_vpc_attachment" "deductions_private_vpc" {
    subnet_ids         = module.vpc.private_subnets
    transit_gateway_id = var.transit_gateway_id
    vpc_id             = module.vpc.vpc_id

    tags = {
        CreatedBy   = var.repo_name
        Environment = var.environment
        Name = "${var.environment}-deductions-private-vpc"
    }
}

resource "aws_route" "deductions_private_private_to_gocd" {
    route_table_id            = module.vpc.private_route_table_ids[0]
    destination_cidr_block    = var.gocd_cidr
    transit_gateway_id        = var.transit_gateway_id
}

resource "aws_route" "deductions_private_public_to_gocd" {
    route_table_id            = module.vpc.public_route_table_ids[0]
    destination_cidr_block    = var.gocd_cidr
    transit_gateway_id        = var.transit_gateway_id
}