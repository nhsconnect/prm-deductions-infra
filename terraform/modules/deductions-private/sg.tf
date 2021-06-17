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
