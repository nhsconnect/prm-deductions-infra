output "vpc_id" {
  value = local.mhs_vpc_id
}

output "private_mhs_vpc_peering_id" {
  value = aws_vpc_peering_connection.private_mhs.id
}

resource "aws_ssm_parameter" "deductions_core_vpc_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/mhs-vpc-id"
  type = "String"
  value = local.mhs_vpc_id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}