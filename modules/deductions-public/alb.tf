resource "aws_alb" "alb" {
  name            = "${var.environment}-${var.component_name}-alb"
  subnets         = module.vpc.public_subnets

  security_groups = [aws_security_group.alb-sg.id]
}