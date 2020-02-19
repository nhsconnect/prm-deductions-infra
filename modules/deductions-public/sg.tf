resource "aws_security_group" "alb-sg" {
    name        = "${var.environment}-${var.component_name}-alb-sg"
    description = "controls access to the ALB"
    vpc_id      = module.vpc.vpc_id
    

    ingress {
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        cidr_blocks = var.allowed_public_ips
    }

    ingress {
        protocol    = "tcp"
        from_port   = 443
        to_port     = 443
        cidr_blocks = var.allowed_public_ips
    }

    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-${var.component_name}-alb-sg"
    }
}

# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs-tasks-sg" {
    name        = "${var.environment}-${var.component_name}-ecs-tasks-sg"
    description = "allow inbound access from the ALB only"
    vpc_id      = module.vpc.vpc_id


    ingress {
        protocol        = "tcp"
        from_port       = "3000"
        to_port         = "3000"
        security_groups = [aws_security_group.alb-sg.id]
    }

    egress {
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-${var.component_name}-ecs-tasks-sg"
    }
}
