resource "aws_rds_cluster" "db-cluster" {
    cluster_identifier      = "${var.environment}-ehr-db-cluster"
    engine                  = "aurora-postgresql"
    database_name           = "ehrdb"
    master_username         = data.aws_ssm_parameter.db-username.value
    master_password         = data.aws_ssm_parameter.db-password.value
    backup_retention_period = 5
    preferred_backup_window = "07:00-09:00"
    vpc_security_group_ids  = [aws_security_group.db-sg.id]
    apply_immediately       = true
    db_subnet_group_name    = aws_db_subnet_group.db-cluster-subnet-group.name
    skip_final_snapshot = true

    tags = {
      CreatedBy   = var.repo_name
      Environment = var.environment
    }
}

resource "aws_ssm_parameter" "rds_endpoint" {
    name = "/repo/${var.environment}/prm-deductions-infra/output/core-rds-endpoint"
    type = "String"
    value = aws_rds_cluster.db-cluster.endpoint
    tags = {
      CreatedBy   = var.repo_name
      Environment = var.environment
    }
}

resource "aws_db_subnet_group" "db-cluster-subnet-group" {
  name       = "${var.environment}-ehr-db-subnet-group"
  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "${var.environment}-ehr-db-subnet-group"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_rds_cluster_instance" "ehr-db-instances" {
  count                 = 1
  identifier            = "${var.environment}-ehr-db-instance-${count.index}"
  cluster_identifier    = aws_rds_cluster.db-cluster.id
  instance_class        = "db.t3.medium"
  engine                = "aurora-postgresql"
  db_subnet_group_name  = aws_db_subnet_group.db-cluster-subnet-group.name
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}
