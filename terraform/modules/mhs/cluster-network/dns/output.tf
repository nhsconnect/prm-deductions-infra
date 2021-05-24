output "dns_ip_addresses" {
  value = aws_instance.dns.*.private_ip
}

output "security_group_id" {
  value = aws_security_group.dns-sg.id
}

resource "aws_ssm_parameter" "dns_ip_address_0" {
    name = "/repo/${var.environment}/output/${var.repo_name}/${var.cluster_name}-dns-ip-0"
    type  = "String"
    value = aws_instance.dns[0].private_ip
    tags = {
      CreatedBy   = var.repo_name
      Environment = var.environment
    }
}

resource "aws_ssm_parameter" "dns_ip_address_1" {
    name = "/repo/${var.environment}/output/${var.repo_name}/${var.cluster_name}-dns-ip-1"
    type  = "String"
    value = aws_instance.dns[1].private_ip
    tags = {
      CreatedBy   = var.repo_name
      Environment = var.environment
    }
}
