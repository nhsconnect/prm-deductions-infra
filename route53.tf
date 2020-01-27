
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
  name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/${var.environment}/private_root_zone_id"
  type  = "String"
  value = aws_route53_zone.private.zone_id
}
