resource "aws_security_group" "ecs-tasks-sg" {
    name        = "${var.environment}-${var.component_name}-ecs-tasks-sg"
    vpc_id      = module.vpc.vpc_id

    ingress {
        description     = "Allow traffic from public and internal ALB to ehr-repo service"
        protocol        = "tcp"
        from_port       = "3000"
        to_port         = "3000"
        security_groups = [
          aws_security_group.core-alb-sg.id,
          aws_security_group.core-alb-internal-sg.id
        ]
    }

    egress {
        description = "Allow All Outbound"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-${var.component_name}-ecs-tasks-sg"
    }
}

resource "aws_security_group" "db-sg" {
    name        = "db-sg"
    vpc_id      = module.vpc.vpc_id

    ingress {
        description     = "Allow traffic from ehr-repo to the db"
        protocol        = "tcp"
        from_port       = "5432"
        to_port         = "5432"
        security_groups = [aws_security_group.ecs-tasks-sg.id,
        aws_security_group.bastion_az1_sg.id]
    }

    tags = {
        Name = "db-sg"
    }
}

resource "aws_security_group" "core-alb-sg" {
    name        = "${var.environment}-${var.component_name}-alb-sg"
    description = "controls access to the ALB"
    vpc_id      = module.vpc.vpc_id

    ingress {
        description = "Allow Whitelisted Traffic to access Core ALB"
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        cidr_blocks = var.allowed_public_ips
    }

    egress {
        description = "Allow All Outbound"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-${var.component_name}-alb-sg"
    }
}

resource "aws_security_group" "core-alb-internal-sg" {
    name        = "${var.environment}-${var.component_name}-alb-internal-sg"
    description = "controls access to the ALB"
    vpc_id      = module.vpc.vpc_id

    ingress {
        description = "Allow deductions private subnet to access Core internal ALB"
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        cidr_blocks = [var.allowed_cidr]
    }

    egress {
        description = "Allow All Outbound"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-${var.component_name}-alb-internal-sg"
    }
}
