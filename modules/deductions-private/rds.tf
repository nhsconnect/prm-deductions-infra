resource "aws_rds_cluster" "db_cluster" {
    cluster_identifier      = "${var.environment}-gp-to-repo-db-cluster"
    engine                  = "aurora-postgresql"
    database_name           = "gp-to-repo-db"
    master_username         = data.aws_ssm_parameter.db-username.value
    master_password         = data.aws_ssm_parameter.db-password.value
    backup_retention_period = 5
    preferred_backup_window = "07:00-09:00"
    vpc_security_group_ids  = [aws_security_group.gp-to-repo-db-sg.id]
    apply_immediately       = true
    db_subnet_group_name    = aws_db_subnet_group.gp_to_repo_db_cluster_subnet_group.name
    skip_final_snapshot = true

    tags = {
      CreatedBy   = var.repo_name
      Environment = var.environment
    }
}

resource "aws_ssm_parameter" "rds_endpoint" {
    name = "/repo/${var.environment}/output/${var.repo_name}/gp-to-repo-rds-endpoint"
    type = "String"
    value = aws_rds_cluster.db_cluster.endpoint
    tags = {
      CreatedBy   = var.repo_name
      Environment = var.environment
    }
}

resource "aws_db_subnet_group" "gp_to_repo_db_cluster_subnet_group" {
  name       = "${var.environment}-gp-to-repo-db-subnet-group"
  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "${var.environment}-gp-to-repo-db-subnet-group"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_rds_cluster_instance" "gp_to_repo_db_instances" {
  count                 = 1
  identifier            = "${var.environment}-gp-to-repo-db-instance-${count.index}"
  cluster_identifier    = aws_rds_cluster.db_cluster.id
  instance_class        = "db.t3.medium"
  engine                = "aurora-postgresql"
  db_subnet_group_name  = aws_db_subnet_group.gp_to_repo_db_cluster_subnet_group.name

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}