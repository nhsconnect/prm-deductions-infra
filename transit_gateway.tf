resource "aws_ec2_transit_gateway" "main" {
  description = "Repository ${var.environment} main transit gateway"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
    Name = "${var.environment}-repository-main"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "gocd_vpc" {
  // TODO: get gocd subnet id dynamically
  subnet_ids         = ["subnet-08e512213a8c987cb"]
  transit_gateway_id = aws_ec2_transit_gateway.main.id
  vpc_id             = data.aws_ssm_parameter.gocd_vpc.value

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
    Name = "${var.environment}-gocd-vpc"
  }
}

resource "aws_route" "gocd_to_mhs" {
  route_table_id            = data.aws_ssm_parameter.gocd_route_table_id.value
  destination_cidr_block    = var.mhs_vpc_cidr_block
  transit_gateway_id        = aws_ec2_transit_gateway.main.id
}

data "aws_ssm_parameter" "gocd_route_table_id" {
  name = "/repo/${var.gocd_environment}/output/prm-gocd-infra/gocd-route-table-id"
}