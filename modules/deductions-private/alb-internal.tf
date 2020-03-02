resource "aws_alb" "alb-internal" {
  name            = "${var.environment}-${var.component_name}-alb-int"
  subnets         = module.vpc.private_subnets
  security_groups = [aws_security_group.private-alb-internal-sg.id]
  internal        = true
}
