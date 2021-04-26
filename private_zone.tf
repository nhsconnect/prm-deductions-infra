
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

resource "aws_route53_zone" "environment_private_with_test_harness" {
  count = var.deploy_mhs_test_harness ? 1 : 0
  name = "${var.environment}.non-prod.patient-deductions.nhs.uk"
  vpc {
    vpc_id = local.deductions_core_vpc_id
  }
  vpc {
    vpc_id = local.deductions_private_vpc_id
  }
  vpc {
    vpc_id = local.repo_mhs_vpc_id
  }
  vpc {
    vpc_id = local.test_harness_mhs_vpc_id
  }
}


resource "aws_route53_zone" "environment_private" {
  count = var.deploy_mhs_test_harness ? 0 : 1
  name = "${var.environment}.non-prod.patient-deductions.nhs.uk"
  vpc {
    vpc_id = local.deductions_core_vpc_id
  }
  vpc {
    vpc_id = local.deductions_private_vpc_id
  }
  vpc {
    vpc_id = local.repo_mhs_vpc_id
  }
}

resource "aws_ssm_parameter" "environment_private_zone_id" {
  name =  "/repo/${var.environment}/output/${var.repo_name}/environment-private-zone-id"
  type  = "String"
  value = var.deploy_mhs_test_harness ? join(",", aws_route53_zone.environment_private_with_test_harness.*.zone_id) : join(",", aws_route53_zone.environment_private.*.zone_id)

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
