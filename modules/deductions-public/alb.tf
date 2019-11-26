resource "aws_alb" "alb" {
  name            = "${var.environment}-${var.component_name}-alb"
  subnets         = [aws_subnet.public-subnets[0].id, 
                     aws_subnet.public-subnets[1].id]

  security_groups = [aws_security_group.lb-sg.id]
}

resource "aws_alb_target_group" "alb-tg" {
  name        = "${var.environment}-${var.component_name}-alb-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main-vpc.id
  target_type = "ip"
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

resource "aws_alb_listener" "alb-listener-https" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "443"
  protocol          = "HTTPS"

  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.portal_acm_certificate.arn

  default_action {
    target_group_arn = aws_alb_target_group.alb-tg.arn
    type             = "forward"
  }
}