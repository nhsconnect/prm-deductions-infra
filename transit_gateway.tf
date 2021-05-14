resource "aws_ec2_transit_gateway" "main" {
  description = "repository-main-transit-gateway"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "gocd_vpc" {
  // TODO: get gocd subnet id dynamically
  subnet_ids         = ["subnet-08e512213a8c987cb"]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = data.aws_ssm_parameter.gocd_vpc.value
}

resource "aws_route" "gocd_to_core" {
  route_table_id            = data.aws_ssm_parameter.route_table_id.value
  destination_cidr_block    = var.deductions_core_cidr
  transit_gateway_id        = aws_ec2_transit_gateway.main.id
}

data "aws_ssm_parameter" "route_table_id" {
  name = "/repo/${var.gocd_environment}/output/prm-gocd-infra/gocd-route-table-id"
}