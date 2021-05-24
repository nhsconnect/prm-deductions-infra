
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

resource "aws_route53_zone" "environment_private" {
  name = "${var.environment}.non-prod.patient-deductions.nhs.uk"
  # NOTE: The aws_route53_zone vpc argument accepts multiple configuration
  #       blocks. The below usage of the single vpc configuration, the
  #       lifecycle configuration, and the aws_route53_zone_association
  #       resource is to associate with test harness conditionally
  vpc {
    vpc_id = local.deductions_private_vpc_id
  }

  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_zone_association" "core" {
  zone_id = aws_route53_zone.environment_private.zone_id
  vpc_id = local.deductions_core_vpc_id
}

resource "aws_route53_zone_association" "gocd" {
  zone_id = aws_route53_zone.environment_private.zone_id
  vpc_id = data.aws_ssm_parameter.gocd_vpc.value
}

resource "aws_route53_zone_association" "repo_mhs" {
  zone_id = aws_route53_zone.environment_private.zone_id
  vpc_id = local.repo_mhs_vpc_id
}

resource "aws_route53_zone_association" "test_harness_mhs" {
  count = var.deploy_mhs_test_harness ? 1 : 0
  zone_id = aws_route53_zone.environment_private.zone_id
  vpc_id = local.test_harness_mhs_vpc_id
}

resource "aws_ssm_parameter" "environment_private_zone_id" {
  name =  "/repo/${var.environment}/output/${var.repo_name}/environment-private-zone-id"
  type  = "String"
  value = aws_route53_zone.environment_private.zone_id

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

data "aws_ssm_parameter" "gocd_vpc" {
  name = "/repo/prod/output/prm-gocd-infra/gocd-vpc-id"
}