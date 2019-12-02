resource "aws_security_group" "ecs-tasks-sg" {
    name        = "${var.environment}-${var.component_name}-ecs-tasks-sg"
    vpc_id      = module.vpc.vpc_id

    # ingress {
    #     description     = "Allow traffic from ALB to PDS Adaptor"
    #     protocol        = "tcp"
    #     from_port       = "3000"
    #     to_port         = "3000"
    #     security_groups = [aws_security_group.pds-adaptor-lb-sg.id]
    # }

    # ingress {
    #     description     = "Allow traffic from ALB to GP2GP Adaptor"
    #     protocol        = "tcp"
    #     from_port       = "80"
    #     to_port         = "80"
    #     security_groups = [aws_security_group.pds-adaptor-lb-sg.id]
    # }

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
        Name = "${var.environment}-pds-adaptor-${var.component_name}-alb-sg"
    }
}