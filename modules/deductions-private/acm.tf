

resource "aws_acm_certificate" "gp2gp-cert" {
  domain_name       = "${var.environment}.gp2gp-adaptor.patient-deductions.nhs.uk"

  validation_method = "DNS"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_acm_certificate" "gp-to-repo-cert" {
  domain_name       = "${var.environment}.gp-to-repo.patient-deductions.nhs.uk"

  validation_method = "DNS"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_acm_certificate" "repo-to-gp-cert" {
  domain_name       = "${var.environment}.repo-to-gp.patient-deductions.nhs.uk"

  validation_method = "DNS"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_acm_certificate" "generic-component-cert" {
  domain_name       = "${var.environment}.generic-component.patient-deductions.nhs.uk"

  validation_method = "DNS"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_acm_certificate" "mq-admin-cert" {
  domain_name       = "${var.environment}.mq-admin.patient-deductions.nhs.uk"

  validation_method = "DNS"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_route53_record" "gp2gp-cert-validation-record" {
  for_each = {
    for dvo in aws_acm_certificate.gp2gp-cert.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "gp2gp-cert-validation" {
  certificate_arn = aws_acm_certificate.gp2gp-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.gp2gp-cert-validation-record : record.fqdn]
}

resource "aws_route53_record" "gp-to-repo-cert-validation-record" {
  for_each = {
    for dvo in aws_acm_certificate.gp-to-repo-cert.domain_validation_options : dvo.domain_name => {
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

resource "aws_route53_record" "repo-to-gp-cert-validation-record" {
  for_each = {
  for dvo in aws_acm_certificate.repo-to-gp-cert.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "gp-to-repo-cert-validation" {
  certificate_arn = aws_acm_certificate.gp-to-repo-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.gp-to-repo-cert-validation-record : record.fqdn]
}

resource "aws_acm_certificate_validation" "repo-to-gp-cert-validation" {
  certificate_arn = aws_acm_certificate.repo-to-gp-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.repo-to-gp-cert-validation-record : record.fqdn]
}

resource "aws_route53_record" "generic-component-cert-validation-record" {
  for_each = {
    for dvo in aws_acm_certificate.generic-component-cert.domain_validation_options : dvo.domain_name => {
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

resource "aws_acm_certificate_validation" "generic-component-cert-validation" {
  certificate_arn = aws_acm_certificate.generic-component-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.generic-component-cert-validation-record : record.fqdn]
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
  zone_id         = data.aws_ssm_parameter.root_zone_id.value
}

resource "aws_acm_certificate_validation" "mq-admin-cert-validation" {
  certificate_arn = aws_acm_certificate.mq-admin-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.mq-admin-cert-validation-record : record.fqdn]
}
