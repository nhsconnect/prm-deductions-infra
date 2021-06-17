resource "aws_security_group" "mq_sg" {
    vpc_id = module.vpc.vpc_id
    name   = "deductor-mq-sg"

    tags = {
        Name = "deductor-mq-b-sg"
        CreatedBy   = var.repo_name
        Environment = var.environment
    }
}

resource "aws_security_group_rule" "local_mq_access" {
    type              = "ingress"
    security_group_id = aws_security_group.mq_sg.id
    description     = "Allow traffic from within the same vpc"
    protocol        = "tcp"
    from_port       = "5671"
    to_port         = "5671"
    cidr_blocks     = [var.cidr]
}

resource "aws_security_group_rule" "ingress_int_alb_to_mq_admin" {
    type                = "ingress"
    security_group_id   = aws_security_group.mq_sg.id
    description         = "Allow traffic from Internal ALB to MQ Admin Console"
    protocol            = "tcp"
    from_port           = "8162"
    to_port             = "8162"
    source_security_group_id    = aws_security_group.private-alb-internal-sg.id
}

 resource "aws_security_group_rule" "vpn_to_mq" {
     type                = "ingress"
     security_group_id   = aws_security_group.mq_sg.id
     description         = "Allow traffic from VPN to MQ"
     protocol            = "tcp"
     from_port           = "61614"
     to_port             = "61614"
     source_security_group_id    = aws_security_group.vpn.id
 }

resource "aws_security_group_rule" "ingress_worker_gocd_agent" {
    type                = "ingress"
    security_group_id   = aws_security_group.mq_sg.id
    description         = "Access to AMQ from gocd agent running e2e tests"
    protocol            = "tcp"
    from_port           = "61614"
    to_port             = "61614"
    cidr_blocks         = [var.gocd_cidr]
}

resource "aws_security_group_rule" "ingress_message_handler_openwire_ecs_tasks" {
    type                = "ingress"
    security_group_id   = aws_security_group.mq_sg.id
    description         = "Access to AMQ from gp2gp-message-handler ECS Task"
    protocol            = "tcp"
    from_port           = "61617"
    to_port             = "61617"
    source_security_group_id     = aws_security_group.gp2gp-message-handler-ecs-task-sg.id
}

resource "aws_security_group_rule" "repo_ingress_mhs" {
  type                = "ingress"
  security_group_id   = aws_security_group.mq_sg.id
  description         = "Access to queues from repo MHS VPC"
  protocol            = "tcp"
  from_port           = "5671"
  to_port             = "5671"
  cidr_blocks         = [var.repo_mhs_vpc_cidr_block]
}

resource "aws_security_group_rule" "test_harness_ingress_mhs" {
    count = var.test_harness_mhs_vpc_cidr_block != "" ? 1 : 0
    type                = "ingress"
    security_group_id   = aws_security_group.mq_sg.id
    description         = "Access to queues from test harness MHS VPC"
    protocol            = "tcp"
    from_port           = "5671"
    to_port             = "5671"
    cidr_blocks         = [var.test_harness_mhs_vpc_cidr_block]
}

resource "aws_security_group_rule" "egress_all" {
  type                = "egress"
  security_group_id   = aws_security_group.mq_sg.id
  description         = "Allow All Outbound"
  protocol            = "tcp"
  from_port           = "0"
  to_port             = "0"
  cidr_blocks         = ["0.0.0.0/0"]
}

resource "aws_security_group" "administration-portal-ecs-task-sg" {
    name        = "${var.environment}-administration-portal-ecs-task-sg"
    vpc_id      = module.vpc.vpc_id

    ingress {
        description     = "Allow traffic from ALB to Administration Portal Task"
        protocol        = "tcp"
        from_port       = "3000"
        to_port         = "3000"
        security_groups = [aws_security_group.deductions-private-alb-sg.id]
    }

    ingress {
        description     = "Allow traffic from ALB to Administration Portal Task"
        protocol        = "tcp"
        from_port       = "80"
        to_port         = "80"
        security_groups = [aws_security_group.deductions-private-alb-sg.id]
    }

    ingress {
        description     = "Allow traffic from Internal ALB to Administration Portal Task"
        protocol        = "tcp"
        from_port       = "3000"
        to_port         = "3000"
        security_groups = [aws_security_group.private-alb-internal-sg.id]
    }

    ingress {
        description     = "Allow traffic from Internal ALB to Administration Portal Task"
        protocol        = "tcp"
        from_port       = "80"
        to_port         = "80"
        security_groups = [aws_security_group.private-alb-internal-sg.id]
    }

    egress {
        description = "Allow All Outbound"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-administration-portal-ecs-task-sg"
        CreatedBy   = var.repo_name
        Environment = var.environment
    }
}

resource "aws_security_group" "gp2gp-message-handler-ecs-task-sg" {
    name        = "${var.environment}-gp2gp-message-handler-ecs-task-sg"
    vpc_id      = module.vpc.vpc_id

    egress {
        description = "Allow All Outbound"
        protocol    = "-1"
        from_port   = 0
        to_port     = 0
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-gp2gp-message-handler-ecs-task-sg"
        CreatedBy   = var.repo_name
        Environment = var.environment
    }
}

resource "aws_security_group" "deductions-private-alb-sg" {
    name        = "${var.environment}-${var.component_name}-alb-sg"
    description = "controls access to the ALB"
    vpc_id      = module.vpc.vpc_id

    egress {
        description = "Allow All Outbound"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-deductions-private-alb-sg"
        CreatedBy   = var.repo_name
        Environment = var.environment
    }
}

resource "aws_security_group" "private-alb-internal-sg" {
    name        = "${var.environment}-${var.component_name}-alb-internal-sg"
    description = "Internal ALB for deductions-private VPC"
    vpc_id      = module.vpc.vpc_id

    ingress {
        description = "Allow traffic from deductions-private VPC"
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        cidr_blocks = [var.cidr]
    }

    ingress {
        protocol    = "tcp"
        from_port   = 443
        to_port     = 443
        // TODO: Move to a separate, GoCD dedicated security group
        cidr_blocks = [var.cidr, var.gocd_cidr]
    }

    egress {
        description = "Allow All Outbound"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-deductions-private-alb-internal-sg"
        CreatedBy   = var.repo_name
        Environment = var.environment
    }
}

resource "aws_security_group" "ecr-endpoint-sg" {
  name        = "${var.environment}-${var.component_name}-ecr-endpoint-sg"
  description = "Taffic for the ECR VPC endpoint."
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    # Allow to pull images from the local network
    cidr_blocks = [var.cidr]
  }

  tags = {
    Name            = "${var.environment}-${var.component_name}-ecr-endpoint-sg"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_security_group" "logs-endpoint-sg" {
  name        = "${var.environment}-${var.component_name}-logs-endpoint-sg"
  description = "Traffic for the CloudWatch Logs VPC endpoint."
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    # Allow to log from the local network
    cidr_blocks = [var.cidr]
  }

  tags = {
    Name            = "${var.environment}-${var.component_name}-logs-endpoint-sg"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
