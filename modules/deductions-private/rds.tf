resource "aws_rds_cluster" "gp_to_repo_db_cluster" {
    cluster_identifier      = "${var.environment}-gp-to-repo-db-cluster"
    engine                  = "aurora-postgresql"
    database_name           = "gptorepodb"
    master_username         = data.aws_ssm_parameter.gp-to-repo-db-username.value
    master_password         = data.aws_ssm_parameter.gp-to-repo-db-password.value
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

resource "aws_ssm_parameter" "gp_to_repo_rds_endpoint" {
    name = "/repo/${var.environment}/output/${var.repo_name}/gp-to-repo-rds-endpoint"
    type = "String"
    value = aws_rds_cluster.gp_to_repo_db_cluster.endpoint
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
  cluster_identifier    = aws_rds_cluster.gp_to_repo_db_cluster.id
  instance_class        = "db.t3.medium"
  engine                = "aurora-postgresql"
  db_subnet_group_name  = aws_db_subnet_group.gp_to_repo_db_cluster_subnet_group.name

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_rds_cluster" "repo_to_gp_db_cluster" {
  cluster_identifier      = "${var.environment}-repo-to-gp-db-cluster"
  engine                  = "aurora-postgresql"
  database_name           = "repotogpdb"
  master_username         = data.aws_ssm_parameter.repo-to-gp-db-username.value
  master_password         = data.aws_ssm_parameter.repo-to-gp-db-password.value
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  vpc_security_group_ids  = [aws_security_group.repo-to-gp-db-sg.id]
  apply_immediately       = true
  db_subnet_group_name    = aws_db_subnet_group.repo_to_gp_db_cluster_subnet_group.name
  skip_final_snapshot = true

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_ssm_parameter" "repo_to_gp_rds_endpoint" {
  name = "/repo/${var.environment}/output/${var.repo_name}/repo-to-gp-rds-endpoint"
  type = "String"
  value = aws_rds_cluster.repo_to_gp_db_cluster.endpoint
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_db_subnet_group" "repo_to_gp_db_cluster_subnet_group" {
  name       = "${var.environment}-repo-to-gp-db-subnet-group"
  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "${var.environment}-repo-to-gp-db-subnet-group"
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_rds_cluster_instance" "repo_to_gp_db_instances" {
  count                 = 1
  identifier            = "${var.environment}-repo-to-gp-db-instance-${count.index}"
  cluster_identifier    = aws_rds_cluster.repo_to_gp_db_cluster.id
  instance_class        = "db.t3.medium"
  engine                = "aurora-postgresql"
  db_subnet_group_name  = aws_db_subnet_group.repo_to_gp_db_cluster_subnet_group.name

  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}