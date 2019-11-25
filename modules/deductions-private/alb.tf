resource "aws_alb" "alb" {
  name            = "${var.environment}-${var.component_name}-pds-a-alb"
  subnets         = module.vpc.public_subnets 
  security_groups = [aws_security_group.pds-adaptor-lb-sg.id]
}

resource "aws_alb_target_group" "alb-tg" {
  name        = "${var.environment}-${var.component_name}-pds-a-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = module.vpc.vpc_id
  target_type = "ip"
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
    values = ["dev.pds-adaptor.patient-dedutions.nhs.uk"]
  }
}