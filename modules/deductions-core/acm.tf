resource "aws_acm_certificate" "certificate" {
  domain_name       = "${var.environment}.ehr-repo.patient-deductions.nhs.uk"

  validation_method = "DNS"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_route53_record" "certificate-validation-record" {
  name    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type
  zone_id = data.aws_ssm_parameter.root_zone_id.value
  records = [aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate-validation" {
  certificate_arn = aws_acm_certificate.certificate.arn

  validation_record_fqdns = [
    aws_route53_record.certificate-validation-record.fqdn
  ]
}
