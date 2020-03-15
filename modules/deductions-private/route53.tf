resource "aws_route53_record" "mq-console-r53-record" {
  zone_id = data.aws_ssm_parameter.private_zone_id.value
  name    = "${var.environment}.mq-admin"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.alb-internal.dns_name]
}