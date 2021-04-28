resource "aws_route53_zone" "environment_public" {
  name = "${var.environment}.non-prod.patient-deductions.nhs.uk"

  tags = {
    CreatedBy = var.repo_name
  }
}

data "aws_ssm_parameter" "non_prod_public_zone" {
  name = "/repo/output/prm-deductions-base-infra/non-prod-public-zone-id"
}

resource "aws_route53_record" "environment_ns" {
  name = "${var.environment}.non-prod.patient-deductions.nhs.uk"
  ttl = 30
  type = "NS"
  zone_id = data.aws_ssm_parameter.non_prod_public_zone.value

  records = aws_route53_zone.environment_public.name_servers
}

resource "aws_ssm_parameter" "environment_public_zone_id" {
  name =  "/repo/${var.environment}/output/${var.repo_name}/environment-public-zone-id"
  type  = "String"
  value = aws_route53_zone.environment_public.zone_id

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}