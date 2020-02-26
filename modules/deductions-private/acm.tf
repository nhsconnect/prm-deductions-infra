resource "aws_acm_certificate" "certificate" {
  domain_name       = "${var.environment}.admin.patient-deductions.nhs.uk"

  # subject_alternative_names = [
  #   "${var.environment}.admin.patient-deductions.nhs.uk"]

  validation_method = "DNS"
  
}

resource "aws_route53_record" "cert_validation" {
  name    = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_name}"
  type    = "${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_type}"
  zone_id = data.aws_ssm_parameter.root_zone_id.value
  records = ["${aws_acm_certificate.certificate.domain_validation_options.0.resource_record_value}"]
  ttl     = 60
}

# resource "aws_route53_record" "cert_validation_alt1" {
#   name    = "${aws_acm_certificate.certificate.domain_validation_options.1.resource_record_name}"
#   type    = "${aws_acm_certificate.certificate.domain_validation_options.1.resource_record_type}"
#   zone_id = data.aws_ssm_parameter.root_zone_id.value
#   records = ["${aws_acm_certificate.certificate.domain_validation_options.1.resource_record_value}"]
#   ttl     = 60
# }

# resource "aws_route53_record" "cert_validation_alt2" {
#   name    = "${aws_acm_certificate.certificate.domain_validation_options.2.resource_record_name}"
#   type    = "${aws_acm_certificate.certificate.domain_validation_options.2.resource_record_type}"
#   zone_id = data.aws_ssm_parameter.root_zone_id.value
#   records = ["${aws_acm_certificate.certificate.domain_validation_options.2.resource_record_value}"]
#   ttl     = 60
# }

resource "aws_acm_certificate_validation" "default" {
  certificate_arn = "${aws_acm_certificate.certificate.arn}"

  validation_record_fqdns = [
    "${aws_route53_record.cert_validation.fqdn}"
    # "${aws_route53_record.cert_validation_alt1.fqdn}",
    # "${aws_route53_record.cert_validation_alt2.fqdn}",
  ]
}