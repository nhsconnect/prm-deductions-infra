resource "aws_alb" "alb" {
  name            = "${var.environment}-${var.component_name}-alb"
  subnets         = module.vpc.public_subnets
  security_groups = [aws_security_group.pds-adaptor-lb-sg.id]
}

resource "aws_alb_target_group" "alb-tg" {
  name        = "${var.environment}-${var.component_name}-pds-a-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  deregistration_delay = var.pds_deregistration_delay
}

resource "aws_alb_target_group" "gp2gp-alb-tg" {
  name        = "${var.environment}-${var.component_name}-gp2gp-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
  deregistration_delay = var.gp2gp_deregistration_delay

  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 5
    timeout             = 5
    interval            = 10
    path                = "/health"
    port                = 3000
  }
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "alb-listener" {
  load_balancer_arn = aws_alb.alb.arn
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

resource "aws_alb_listener_rule" "pds-adaptor-alb-listener-rule" {
  listener_arn = aws_alb_listener.alb-listener.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.alb-tg.arn
  }

  condition {
    field  = "host-header"
    values = ["${var.environment}.pds-adaptor.patient-deductions.nhs.uk"]
  }
}

resource "aws_alb_listener_rule" "gp2gp-alb-listener-rule" {
  listener_arn = aws_alb_listener.alb-listener.arn
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.gp2gp-alb-tg.arn
  }

  condition {
    field  = "host-header"
    values = ["${var.environment}.gp2gp-adaptor.patient-deductions.nhs.uk"]
  }
}
