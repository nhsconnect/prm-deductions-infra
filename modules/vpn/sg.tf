
resource "aws_security_group" "vpn_sg" {
  name        = "VPN VM ${var.environment} security group"
  description = "Security group for VPN VM"
  vpc_id      = var.vpc_id

  # SSH for provisioning from whitelisted IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = local.allowed_public_ips
  }

  # all traffic from public subnet
  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    cidr_blocks = [
      local.public_subnet_cidr
    ]
  }

  egress {
    # allow all traffic to private SN
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = {
    Name      = "Security group for VPN in ${var.environment}"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
