resource "aws_alb" "alb-internal" {
  name            = "${var.environment}-${var.component_name}-alb-int"
  subnets         = module.vpc.private_subnets
  security_groups = [aws_security_group.private-alb-internal-sg.id]
  internal        = true

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_alb_listener" "int-alb-listener" {
  load_balancer_arn = aws_alb.alb-internal.arn
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
  load_balancer_arn = aws_alb.alb-internal.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy      = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = aws_acm_certificate_validation.gp2gp-cert-validation.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Error"
      status_code  = "501"
    }
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
      values = ["${var.environment}.mq-admin.patient-deductions.nhs.uk"]
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
      values = ["${var.environment}.mq-admin.patient-deductions.nhs.uk"]
    }
  }
}

resource "aws_alb_target_group" "mq-admin-int-alb-tg" {
  name        = "${var.environment}-mq-admin-int-tg"
  port        = 8162
  protocol    = "HTTPS"
  vpc_id      = module.vpc.vpc_id
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
    target_id        = aws_mq_broker.deductor_mq_broker.instances[count.index].ip_address
    port             = 8162
}

resource "aws_lb_listener_certificate" "gp-to-repo-int-listener-cert" {
  listener_arn    = aws_alb_listener.int-alb-listener-https.arn
  certificate_arn = aws_acm_certificate_validation.gp-to-repo-cert-validation.certificate_arn
}

resource "aws_lb_listener_certificate" "repo-to-gp-int-listener-cert" {
  listener_arn    = aws_alb_listener.int-alb-listener-https.arn
  certificate_arn = aws_acm_certificate_validation.repo-to-gp-cert-validation.certificate_arn
}

resource "aws_lb_listener_certificate" "generic-component-int-listener-cert" {
  listener_arn    = aws_alb_listener.int-alb-listener-https.arn
  certificate_arn = aws_acm_certificate_validation.generic-component-cert-validation.certificate_arn
}

resource "aws_lb_listener_certificate" "mq-admin-int-listener-cert" {
  listener_arn    = aws_alb_listener.int-alb-listener-https.arn
  certificate_arn = aws_acm_certificate_validation.mq-admin-cert-validation.certificate_arn
}
