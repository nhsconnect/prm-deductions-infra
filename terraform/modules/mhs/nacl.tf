resource "aws_network_acl" "mhs_public" {
  count = length(var.inbound_sig_ips) > 0 ? 1 : 0
  vpc_id = aws_vpc.mhs_vpc.id
  subnet_ids = aws_subnet.mhs_public.*.id
}

resource "aws_network_acl_rule" "ingress_sig" {
  count = length(var.inbound_sig_ips)
  network_acl_id = aws_network_acl.mhs_public[0].id
  protocol = "tcp"
  rule_action = "allow"
  rule_number = 100 + count.index
  cidr_block = var.inbound_sig_ips[count.index]
  from_port      = -1
  to_port        = -1
}

resource "aws_network_acl_rule" "egress_sig" {
  count = length(var.inbound_sig_ips)
  network_acl_id = aws_network_acl.mhs_public[0].id
  egress = true
  protocol = "tcp"
  rule_action = "allow"
  rule_number = 100 + count.index
  cidr_block = var.inbound_sig_ips[count.index]
  from_port      = -1
  to_port        = -1
}