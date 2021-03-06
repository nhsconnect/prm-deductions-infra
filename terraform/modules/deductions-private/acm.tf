resource "aws_acm_certificate" "mq-admin-cert" {
  domain_name       = "mq-admin.${var.environment_public_zone.name}"

  validation_method = "DNS"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_route53_record" "mq-admin-cert-validation-record" {
  for_each = {
    for dvo in aws_acm_certificate.mq-admin-cert.domain_validation_options : dvo.domain_name => {
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
  zone_id         = var.environment_public_zone.zone_id
}

resource "aws_acm_certificate_validation" "mq-admin-cert-validation" {
  certificate_arn = aws_acm_certificate.mq-admin-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.mq-admin-cert-validation-record : record.fqdn]
}
