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

resource "aws_vpc_peering_connection" "private_to_gocd" {
    peer_vpc_id = data.aws_ssm_parameter.gocd_vpc.value
    vpc_id = module.vpc.vpc_id
    auto_accept = true

    accepter {
        allow_remote_vpc_dns_resolution = true
    }

    requester {
        allow_remote_vpc_dns_resolution = true
    }

    tags = {
        Name = "${var.environment}-deductions-private-gocd-peering"
        CreatedBy   = var.repo_name
        Environment = var.environment
    }
}

resource "aws_route" "private_private_to_gocd" {
    route_table_id            = module.vpc.private_route_table_ids[0]
    destination_cidr_block    = var.gocd_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.private_to_gocd.id
}

resource "aws_route" "private_public_to_gocd" {
    route_table_id            = module.vpc.public_route_table_ids[0]
    destination_cidr_block    = var.gocd_cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.private_to_gocd.id
}

resource "aws_route" "gocd_to_private" {
    route_table_id            = data.aws_ssm_parameter.gocd_route_table_id.value
    destination_cidr_block    = var.cidr
    vpc_peering_connection_id = aws_vpc_peering_connection.private_to_gocd.id
}

data "aws_ssm_parameter" "gocd_vpc" {
    name = "/repo/prod/output/prm-gocd-infra/gocd-vpc-id"
}

data "aws_ssm_parameter" "gocd_route_table_id" {
    name = "/repo/${var.gocd_environment}/output/prm-gocd-infra/gocd-route-table-id"
}