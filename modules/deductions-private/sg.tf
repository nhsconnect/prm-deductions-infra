resource "aws_security_group" "mq_sg" {
    vpc_id = module.vpc.vpc_id
    name   = "deductor-mq-sg"

  tags = {
      Name = "deductor-mq-b-sg"
  }
}

resource "aws_security_group_rule" "ingress_ecs_tasks" {
  type                = "ingress"
  security_group_id   = aws_security_group.mq_sg.id
  description         = "Access to Deductions Private ECS Tasks"
  protocol            = "tcp"
  from_port           = "61614"
  to_port             = "61614"
  source_security_group_id     = aws_security_group.ecs-tasks-sg.id
}

resource "aws_security_group_rule" "ingress_console_nlb" {
  type                = "ingress"
  security_group_id   = aws_security_group.mq_sg.id
  description         = "Access to MQ Admin Console NLB"
  protocol            = "tcp"
  from_port           = "8162"
  to_port             = "8162"
  cidr_blocks         = ["10.20.101.113/32", "10.20.102.41/32"]
}

resource "aws_security_group_rule" "ingress_mhs" {
  type                = "ingress"
  security_group_id   = aws_security_group.mq_sg.id
  description         = "Access to queues from MHS VPC"
  protocol            = "tcp"
  from_port           = "5671"
  to_port             = "5671"
  cidr_blocks         = ["10.33.0.0/16"]
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

resource "aws_security_group" "ecs-tasks-sg" {
    name        = "${var.environment}-${var.component_name}-ecs-tasks-sg"
    vpc_id      = module.vpc.vpc_id

    ingress {
        description     = "Allow traffic from ALB to PDS Adaptor"
        protocol        = "tcp"
        from_port       = "3000"
        to_port         = "3000"
        security_groups = [aws_security_group.pds-adaptor-lb-sg.id]
    }

    ingress {
        description     = "Allow traffic from ALB to GP2GP Adaptor"
        protocol        = "tcp"
        from_port       = "80"
        to_port         = "80"
        security_groups = [aws_security_group.pds-adaptor-lb-sg.id]
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

resource "aws_security_group" "pds-adaptor-lb-sg" {
    name        = "${var.environment}-${var.component_name}-pds-adaptor-lb-sg"
    description = "controls access to the ALB"
    vpc_id      = module.vpc.vpc_id

    ingress {
        description = "Allow Whitelisted Traffic to access PDS Adaptor ALB"
        protocol    = "tcp"
        from_port   = 80
        to_port     = 80
        cidr_blocks = split(",", data.aws_ssm_parameter.inbound_ips.value)
    }

    egress {
        description = "Allow All Outbound"
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "${var.environment}-pds-adaptor-${var.component_name}-lb-sg"
    }
}
