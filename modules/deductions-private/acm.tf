resource "aws_acm_certificate" "admin-portal-cert" {
  domain_name       = "${var.environment}.admin.patient-deductions.nhs.uk"

  validation_method = "DNS"

  tags = {
    Terraform = "true"
    Environment = var.environment
    Deductions-VPC = var.component_name
  }
}

resource "aws_acm_certificate" "gp2gp-cert" {
  domain_name       = "${var.environment}.gp2gp-adaptor.patient-deductions.nhs.uk"

  validation_method = "DNS"

  tags = {
    Terraform = "true"
    Environment = var.environment
    Deductions-VPC = var.component_name
  }
}

resource "aws_acm_certificate" "gp-to-repo-cert" {
  domain_name       = "${var.environment}.gp-to-repo.patient-deductions.nhs.uk"

  validation_method = "DNS"

  tags = {
    Terraform = "true"
    Environment = var.environment
    Deductions-VPC = var.component_name
  }
}

resource "aws_acm_certificate" "generic-component-cert" {
  domain_name       = "${var.environment}.generic-component.patient-deductions.nhs.uk"

  validation_method = "DNS"

  tags = {
    Terraform = "true"
    Environment = var.environment
    Deductions-VPC = var.component_name
  }
}

resource "aws_acm_certificate" "mq-admin-cert" {
  domain_name       = "${var.environment}.mq-admin.patient-deductions.nhs.uk"

  validation_method = "DNS"

  tags = {
    Terraform = "true"
    Environment = var.environment
    Deductions-VPC = var.component_name
  }
}

resource "aws_route53_record" "admin-cert-validation" {
  name    = aws_acm_certificate.admin-portal-cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.admin-portal-cert.domain_validation_options.0.resource_record_type
  zone_id = data.aws_ssm_parameter.root_zone_id.value
  records = [aws_acm_certificate.admin-portal-cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_route53_record" "gp2gp-cert-validation" {
  name    = aws_acm_certificate.gp2gp-cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.gp2gp-cert.domain_validation_options.0.resource_record_type
  zone_id = data.aws_ssm_parameter.root_zone_id.value
  records = [aws_acm_certificate.gp2gp-cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_route53_record" "gp-to-repo-cert-validation" {
  name    = aws_acm_certificate.gp-to-repo-cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.gp-to-repo-cert.domain_validation_options.0.resource_record_type
  zone_id = data.aws_ssm_parameter.root_zone_id.value
  records = [aws_acm_certificate.gp-to-repo-cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_route53_record" "generic-component-cert-validation" {
  name    = aws_acm_certificate.generic-component-cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.generic-component-cert.domain_validation_options.0.resource_record_type
  zone_id = data.aws_ssm_parameter.root_zone_id.value
  records = [aws_acm_certificate.generic-component-cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_route53_record" "mq-admin-cert-validation" {
  name    = aws_acm_certificate.mq-admin-cert.domain_validation_options.0.resource_record_name
  type    = aws_acm_certificate.mq-admin-cert.domain_validation_options.0.resource_record_type
  zone_id = data.aws_ssm_parameter.root_zone_id.value
  records = [aws_acm_certificate.mq-admin-cert.domain_validation_options.0.resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "admin-cert-validation" {
  certificate_arn = aws_acm_certificate.admin-portal-cert.arn

  validation_record_fqdns = [
    aws_route53_record.admin-cert-validation.fqdn
  ]
}

resource "aws_acm_certificate_validation" "gp2gp-cert-validation" {
  certificate_arn = aws_acm_certificate.gp2gp-cert.arn

  validation_record_fqdns = [
    aws_route53_record.gp2gp-cert-validation.fqdn
  ]
}

resource "aws_acm_certificate_validation" "gp-to-repo-cert-validation" {
  certificate_arn = aws_acm_certificate.gp-to-repo-cert.arn

  validation_record_fqdns = [
    aws_route53_record.gp-to-repo-cert-validation.fqdn
  ]
}

resource "aws_acm_certificate_validation" "generic-component-cert-validation" {
  certificate_arn = aws_acm_certificate.generic-component-cert.arn

  validation_record_fqdns = [
    aws_route53_record.generic-component-cert-validation.fqdn
  ]
}

resource "aws_acm_certificate_validation" "mq-admin-cert-validation" {
  certificate_arn = aws_acm_certificate.mq-admin-cert.arn

  validation_record_fqdns = [
    aws_route53_record.mq-admin-cert-validation.fqdn
  ]
}
