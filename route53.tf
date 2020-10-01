
resource "aws_route53_zone" "private" {
  name = "patient-deductions.nhs.uk"
  vpc {
    vpc_id = local.deductions_core_vpc_id
  }
  vpc {
    vpc_id = local.deductions_private_vpc_id
  }
}

# Save the zone IDs to use them in other infra projects
resource "aws_ssm_parameter" "private_zone_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/private-root-zone-id"
  type  = "String"
  value = aws_route53_zone.private.zone_id

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
