resource "aws_route53_record" "mq-console-r53-record" {
  zone_id = var.private_zone_id
  name    = "${var.environment}.mq-admin"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.alb-internal.dns_name]
}