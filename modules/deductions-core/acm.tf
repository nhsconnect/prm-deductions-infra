resource "aws_acm_certificate" "certificate" {
  domain_name       = "${var.environment}.ehr-repo.patient-deductions.nhs.uk"

  validation_method = "DNS"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_route53_record" "certificate-validation-record" {
  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_ssm_parameter.root_zone_id.value
}

resource "aws_acm_certificate_validation" "certificate-validation" {
  certificate_arn = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [for record in aws_route53_record.certificate-validation-record : record.fqdn]
}
