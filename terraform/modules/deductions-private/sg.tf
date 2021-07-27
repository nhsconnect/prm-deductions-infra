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
