resource "aws_alb" "alb-internal" {
  name            = "${var.environment}-mq-admin-alb"
  subnets         = module.vpc.private_subnets
  security_groups = [aws_security_group.vpn_to_mq_admin.id]
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

resource "aws_security_group" "vpn_to_mq_admin" {
  name        = "${var.environment}-vpn-to-${var.component_name}"
  description = "controls access from vpn to mq admin"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Allow vpn to access mq admin ALB"
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    security_groups = [data.aws_ssm_parameter.vpn_sg_id.value]
  }

  egress {
    description = "Allow All Outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.environment}-vpn-to-${var.component_name}-sg"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

data "aws_ssm_parameter" "vpn_sg_id" {
  name = "/repo/${var.environment}/output/prm-deductions-infra/vpn-sg-id"
}

data "aws_ssm_parameter" "gocd_sg_id" {
  name = "/repo/${var.environment}/user-input/external/gocd-agent-sg-id"
}