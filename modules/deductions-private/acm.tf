resource "aws_acm_certificate" "certificate" {
  domain_name       = "patient-deductions.nhs.uk"

  subject_alternative_names = [
    "${var.environment}.gp2gp-adaptor.patient-deductions.nhs.uk"
  ]

  validation_method = "DNS"
}

resource "aws_route53_record" "validation-record-1" {
  name    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type
  zone_id = data.aws_ssm_parameter.root_zone_id.value
  records = [aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value]
  ttl     = "60"
}

resource "aws_route53_record" "validation-record-2" {
  name    = aws_acm_certificate.certificate.domain_validation_options.1.resource_record_name
  type    = aws_acm_certificate.certificate.domain_validation_options.1.resource_record_type
  zone_id = data.aws_ssm_parameter.root_zone_id.value
  records = [aws_acm_certificate.certificate.domain_validation_options.1.resource_record_value]
  ttl     = "60"
}

resource "aws_acm_certificate_validation" "default" {
  certificate_arn = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.validation-record-1.fqdn,
                            aws_route53_record.validation-record-2.fqdn]
}
