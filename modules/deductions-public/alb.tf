resource "aws_alb" "alb" {
  name            = "${var.environment}-${var.component_name}-alb"
  subnets         = module.vpc.public_subnets

  security_groups = [aws_security_group.alb-sg.id]
}

resource "aws_alb_listener" "alb-listener-http" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}