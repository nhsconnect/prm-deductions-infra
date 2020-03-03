resource "aws_route53_record" "mq-console-r53-record" {
  zone_id = data.aws_ssm_parameter.root_zone_id.value
  name    = "${var.environment}.mq-admin"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.deductor_mq_console_nlb[0].dns_name]
}