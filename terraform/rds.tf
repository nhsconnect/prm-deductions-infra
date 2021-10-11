resource "aws_rds_cluster_parameter_group" "repo_databases" {
  name   = "repo-databases"
  family = "aurora-postgresql11"

  parameter {
    name  = "ssl_min_protocol_version"
    value = "TLSv1.2"
  }
}

resource "aws_ssm_parameter" "repo_databases" {
  name = "/repo/${var.environment}/output/${var.repo_name}/repo-databases-parameter-group-name"
  type = "String"
  value = aws_rds_cluster_parameter_group.repo_databases.name

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}