# Instance Security group
resource "aws_security_group" "vpn_sg" {
  name        = "VPN VM ${var.environment} security group"
  description = "Security group for VPN VM"
  vpc_id      = var.vpc_id

  # SSH for provisioning from whitelisted IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = concat(split(",", "${data.aws_ssm_parameter.inbound_ips.value}"),
      ["10.0.0.0/8", "${var.my_ip}/32"])
  }

  # VPN from whitelisted IP
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = concat(split(",", "${data.aws_ssm_parameter.inbound_ips.value}"),
      ["10.0.0.0/8", "${var.my_ip}/32"])
  }

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "udp"
    cidr_blocks = concat(split(",", "${data.aws_ssm_parameter.inbound_ips.value}"),
      ["10.0.0.0/8", "${var.my_ip}/32"])
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
    Name      = "Security group for VPN to ${var.environment}"
  }
}
