resource "aws_security_group" "mq_sg" {
    vpc_id = module.vpc.vpc_id
    name   = "deductor-mq-sg"

    ingress {
        description         = "Access to Deductions Private ECS Tasks"
        protocol            = "tcp"
        from_port           = "61614"
        to_port             = "61614"
        security_groups     = [aws_security_group.ecs-tasks-sg.id]
    }

    ingress {
        description         = "Access to MQ Admin Console NLB"
        protocol            = "tcp"
        from_port           = "8162"
        to_port             = "8162"
        cidr_blocks         = ["10.20.101.113/32", "10.20.102.41/32"]      
    } 

    egress {
        description         = "Allow All Outbound"
        protocol            = "tcp" 
        from_port           = "0"
        to_port             = "0"
        cidr_blocks         = ["0.0.0.0/0"]      
    }         

  tags = {
      Name = "deductor-mq-b-sg"
  }    
}

resource "aws_security_group" "ecs-tasks-sg" {
    name        = "${var.environment}-${var.component_name}-ecs-tasks-sg"
    vpc_id      = module.vpc.vpc_id

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