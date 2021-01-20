output "dns_ip_addresses" {
  value = aws_instance.dns.*.private_ip
}

output "security_group_id" {
  value = aws_security_group.dns-sg.id
}
