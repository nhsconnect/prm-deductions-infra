resource "aws_vpc_endpoint" "ecr" {
    
    vpc_id       = module.vpc.vpc_id
    service_name = "com.amazonaws.${var.region}.ecr.dkr"

    subnet_ids = module.vpc.private_subnets
    vpc_endpoint_type = "Interface"

    security_group_ids = [aws_security_group.ecr-endpoint-sg.id]

    private_dns_enabled = true

    tags = {
        Name            = "${var.environment}-${var.component_name}-ecr-endpoint"
        Terraform       = "true"
        Environment     = var.environment
        Deductions-VPC  = var.component_name
    }
}

# Cloudwatch VPC endpoint
resource "aws_vpc_endpoint" "cloudwatch-logs" {
    vpc_id       = module.vpc.vpc_id
    service_name = "com.amazonaws.${var.region}.logs"
    
    subnet_ids = module.vpc.private_subnets
    vpc_endpoint_type = "Interface"

    security_group_ids = [aws_security_group.logs-endpoint-sg.id]

    private_dns_enabled = true

    tags = {
        Name            = "${var.environment}-${var.component_name}-logs-endpoint"
        Terraform       = "true"
        Environment     = var.environment
        Deductions-VPC  = var.component_name
    }
}

