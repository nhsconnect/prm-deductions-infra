resource "aws_route53_zone" "mhs" {
  name = var.mhs_cluster_domain_name
  vpc {
    vpc_id = local.mhs_vpc_id
  }
  vpc {
    vpc_id = var.deductions_private_vpc_id
  }

  tags = {
    Name = "${var.environment}-${var.cluster_name}-mhs-hosted-zone"
    Environment = var.environment
    CreatedBy = var.repo_name
  }
}