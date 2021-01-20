resource "aws_security_group" "dns-sg" {
    name        = "mhs-${var.environment}-${var.cluster_name}-dns-server-sg"
    description = "DNS server access in MHS VPC"
    vpc_id      = var.mhs_vpc_id

    # DNS traffic
    ingress {
        protocol    = "tcp"
        from_port   = 53
        to_port     = 53
        cidr_blocks = [var.allowed_cidr]
    }

    ingress {
        protocol    = "udp"
        from_port   = 53
        to_port     = 53
        cidr_blocks = [var.allowed_cidr]
    }

    # For debugging
    ingress {
        protocol    = "tcp"
        from_port   = 22
        to_port     = 22
        cidr_blocks = ["10.0.0.0/8"] # All local networks
    }

    ingress {
        protocol    = "icmp"
        from_port   = -1
        to_port     = -1
        cidr_blocks = ["10.0.0.0/8"] # All local networks
    }

    egress {
        from_port = 0
        to_port   = 0
        protocol  = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "mhs-${var.environment}-${var.cluster_name}-dns-server"
        Environment = var.environment
        CreatedBy = var.repo_name
    }
}
