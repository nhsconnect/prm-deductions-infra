resource "aws_alb" "alb" {
  name            = "${var.environment}-${var.component_name}-alb"
  subnets         = [aws_subnet.public-subnets[0].id, 
                     aws_subnet.public-subnets[1].id]

  security_groups = [aws_security_group.lb-sg.id]
}