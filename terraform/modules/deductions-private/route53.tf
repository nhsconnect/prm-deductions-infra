resource "aws_route53_record" "mq-console-r53-record" {
  zone_id = var.environment_private_zone.zone_id
  name    = "mq-admin"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.alb-internal.dns_name]
}