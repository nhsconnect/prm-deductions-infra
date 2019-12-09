resource "aws_rds_cluster" "db-cluster" {
    cluster_identifier      = "ehr-db-cluster"
    engine                  = "aurora-postgresql"
    availability_zones      = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
    database_name           = "ehrdb"
    master_username         = data.aws_secretsmanager_secret_version.db-username.secret_string
    master_password         = data.aws_secretsmanager_secret_version.db-password.secret_string
    backup_retention_period = 5
    preferred_backup_window = "07:00-09:00"
    vpc_security_group_ids  = [aws_security_group.db-sg.id]
    apply_immediately       = true
    db_subnet_group_name    = aws_db_subnet_group.db-cluster-subnet-group.name
    skip_final_snapshot = true
}

resource "aws_ssm_parameter" "rds_endpoint" {
    name = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/core/rds_endpoint"
    type = "String"
    value = aws_rds_cluster.db-cluster.endpoint
}

resource "aws_db_subnet_group" "db-cluster-subnet-group" {
  name       = "ehr-db-subnet-group"
  subnet_ids = module.vpc.database_subnets

  tags = {
    Name = "ehr-db-subnet-group"
  }
}

resource "aws_rds_cluster_instance" "ehr-db-instances" {
  count                 = 1
  identifier            = "ehr-db-instance-${count.index}"
  cluster_identifier    = aws_rds_cluster.db-cluster.id
  instance_class        = "db.t3.medium"
  engine                = "aurora-postgresql"
  db_subnet_group_name  = aws_db_subnet_group.db-cluster-subnet-group.name
}
