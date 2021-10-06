resource "aws_alb" "mq-admin" {
  name            = "${var.environment}-mq-admin-alb"
  subnets         = var.deductions_private_vpc_private_subnets
  security_groups = [var.vpn_to_mq_admin_sg_id]
  internal        = true
  drop_invalid_header_fields = true

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_alb_listener" "int-alb-listener" {
  load_balancer_arn = aws_alb.mq-admin.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Error"
      status_code  = "501"
    }
  }
}

resource "aws_alb_listener" "int-alb-listener-https" {
  load_balancer_arn = aws_alb.mq-admin.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-Ext-2018-06"
  certificate_arn = aws_acm_certificate_validation.mq-admin-cert-validation.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Error"
      status_code  = "501"
    }
  }
}

resource aws_ssm_parameter "int-alb-listener-https-arn" {
  name = "/repo/${var.environment}/output/${var.repo_name}/int-alb-listener-https-arn"
  value = aws_alb_listener.int-alb-listener-https.arn
  type = "String"

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_alb_listener_rule" "mq-int-alb-http-listener-rule" {
  listener_arn = aws_alb_listener.int-alb-listener.arn
  priority     = 451

  action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    host_header {
      values = ["mq-admin.${var.environment_public_zone.name}"]
    }
  }
}

resource "aws_alb_listener_rule" "mq-int-alb-https-listener-rule" {
  listener_arn = aws_alb_listener.int-alb-listener-https.arn
  priority     = 450

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.mq-admin-int-alb-tg.arn
  }

  condition {
    host_header {
      values = ["mq-admin.${var.environment_public_zone.name}"]
    }
  }
}

resource "aws_alb_target_group" "mq-admin-int-alb-tg" {
  name        = "${var.environment}-mq-admin-int-tg"
  port        = 8162
  protocol    = "HTTPS"
  vpc_id      = var.deductions_private_vpc_id
  target_type = "ip"
  deregistration_delay = 15
  health_check {
    protocol            = "HTTPS"
    healthy_threshold   = 3
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 10
    path                = "/index.html"
    port                = 8162
    matcher             = "200,304"
  }

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_alb_target_group_attachment" "mq-attachment" {
  count = 2
  target_group_arn = aws_alb_target_group.mq-admin-int-alb-tg.arn
  target_id        = var.mq_broker_instances[count.index].ip_address
  port             = 8162
}


resource "aws_security_group_rule" "vpn_to_mq_admin" {
  type        = "ingress"
  description = "Allow vpn to access mq admin ALB"
  protocol    = "tcp"
  from_port   = 443
  to_port     = 443
  source_security_group_id = var.vpn_sg_id
  security_group_id = var.vpn_to_mq_admin_sg_id
}

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

resource "aws_route53_record" "mq-console-r53-record" {
  zone_id = var.environment_private_zone.zone_id
  name    = "mq-admin"
  type    = "CNAME"
  ttl     = "300"
  records = [aws_alb.mq-admin.dns_name]
}


resource "aws_ssm_parameter" "deductions_private_int_alb_httpl_arn" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-int-alb-httpl-arn"
  type = "String"
  value = aws_alb_listener.int-alb-listener.arn
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_private_int_alb_httpsl_arn" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-int-alb-httpsl-arn"
  type = "String"
  value = aws_alb_listener.int-alb-listener-https.arn
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "deductions_private_alb_internal_dns" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-alb-internal-dns"
  type = "String"
  value = aws_alb.mq-admin.dns_name
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}


resource "aws_ssm_parameter" "deductions_private_alb_internal_id" {
  name = "/repo/${var.environment}/output/${var.repo_name}/deductions-private-alb-internal-id"
  type = "String"
  value = aws_alb.mq-admin.id
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}