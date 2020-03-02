locals {
  root_domain_name = data.aws_route53_zone.public_zone.name
}

resource "aws_route53_record" "vpn-a-record" {
  zone_id = data.aws_ssm_parameter.public_zone_id.value
  name    = "${var.environment}.vpn.${local.root_domain_name}"
  type    = "A"
  ttl     = "3600"
  records = [aws_eip.eip.public_ip]
}
