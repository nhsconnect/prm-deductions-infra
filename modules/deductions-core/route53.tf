# resource "aws_route53_record" "mq-console-r53-record" {
#   zone_id = data.aws_ssm_parameter.root_zone_id.value
#   name    = "${var.environment}.alb"
#   type    = "CNAME"
#   ttl     = "300"
#   records = [aws_alb.alb.dns_name]
# }

resource "aws_route53_record" "alb-r53-record" {
  zone_id = var.private_zone_id
  name    = "${var.environment}.alb"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.alb-internal.dns_name]
}
