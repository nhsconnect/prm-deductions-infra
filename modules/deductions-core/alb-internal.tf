resource "aws_alb" "alb-internal" {
  name            = "${var.environment}-${var.component_name}-alb-int"
  subnets         = module.vpc.private_subnets
  security_groups = [aws_security_group.core-alb-internal-sg.id]
  internal        = true

  tags = {
    Terraform = "true"
    Environment = var.environment
    Deductions-VPC = var.component_name
  }
}

resource "aws_alb_listener" "int-alb-listener-http" {
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
  certificate_arn = aws_acm_certificate_validation.certificate-validation.certificate_arn

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Error"
      status_code  = "501"
    }
  }
}

resource "aws_alb_listener_rule" "alb-internal-check-listener-rule" {
  listener_arn = aws_alb_listener.int-alb-listener-http.arn
  priority     = 200

  action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "ALB Alive and reachable"
      status_code  = "200"
    }
  }

  condition {
    field  = "host-header"
    values = ["${var.environment}.alb.patient-deductions.nhs.uk"]
  }

  depends_on = [aws_alb_listener.int-alb-listener-http]
}
