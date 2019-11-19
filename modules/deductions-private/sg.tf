resource "aws_security_group" "mq_sg" {
    vpc_id = "${module.vpc.vpc_id}"
    name   = "deductor-mq-sg"

    ingress {
        protocol                 = "tcp"
        from_port                = "8162"
        to_port                  = "8162"
        cidr_blocks              = ["10.20.101.0/24", "10.20.102.0/24"]      
    } 

    ingress {
        protocol                 = "tcp"
        from_port                = "8162"
        to_port                  = "8162"
        cidr_blocks              = ["0.0.0.0/0"]      
    } 

    egress {
        protocol                 = "tcp"
        from_port                = "0"
        to_port                  = "0"
        cidr_blocks              = ["0.0.0.0/0"]      
    }         

  tags = {
      Name = "deductor-mq-b-sg"
  }    
}

resource "aws_security_group" "ecs-tasks-sg" {
    name        = "${var.environment}-${var.component_name}-ecs-tasks-sg"
    vpc_id      = "${module.vpc.vpc_id}"

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