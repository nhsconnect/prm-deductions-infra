locals {
  private_key = "${file("${path.module}/../ssh/id_rsa")}"
  public_key = "${file("${path.module}/../ssh/id_rsa.pub")}"
}

resource "aws_key_pair" "vpn_ssh_key" {
  key_name   = "vpn-${var.environment}-ssh-key"
  public_key = local.public_key
}
