resource "aws_alb" "alb" {
  name            = "${var.environment}-${var.component_name}-alb"
  subnets         = [aws_subnet.public-subnets[0].id, 
                     aws_subnet.public-subnets[1].id]

  security_groups = [aws_security_group.lb-sg.id]
}

resource "aws_alb_target_group" "alg-tg" {
  name        = "${var.environment}-${var.component_name}-alg-tg"
  port        = 3000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main-vpc.id
  target_type = "ip"
}

# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "alg-listener" {
  load_balancer_arn = aws_alb.alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.alg-tg.arn
    type             = "forward"
  }
}