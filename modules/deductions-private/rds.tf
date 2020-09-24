# resource "aws_db_instance" "state-db" {
#   identifier              = "${var.environment}-deductions-state-db"
#   allocated_storage       = var.state_db_allocated_storage
#   max_allocated_storage   = 0
#   storage_type            = "gp2"
#   engine                  = "postgres"
#   engine_version          = var.state_db_engine_version
#   instance_class          = var.state_db_instance_class
#   name                    = "gp_to_repo"
#   username                = data.aws_ssm_parameter.db-username.value
#   password                = data.aws_ssm_parameter.db-password.value
#   parameter_group_name    = "default.postgres11"
#   publicly_accessible     = "false"
#   backup_retention_period = 15
#   backup_window           = "19:00-21:00"
#   maintenance_window      = "Sun:00:00-Sun:03:00"
#   skip_final_snapshot     = true

#   db_subnet_group_name   = aws_db_subnet_group.db-cluster-subnet-group.name
#   vpc_security_group_ids = [aws_security_group.state-db-sg.id]
# }

# resource "aws_db_subnet_group" "db-cluster-subnet-group" {
#   name       = "${var.environment}-state-db-subnet-group"
#   subnet_ids = module.vpc.database_subnets # @@@ SHOULD WE ADD ANOTHER SUBNET

#   tags = {
#     Name = "${var.environment}-state-db-subnet-group"
#   }
# }

# resource "aws_ssm_parameter" "rds_endpoint" {
#   name  = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/private/rds_endpoint"
#   type  = "String"
#   value = aws_db_instance.state-db.endpoint
# }

# provider "postgresql" {
#   host            = aws_db_instance.state-db.address
#   port            = aws_db_instance.state-db.port
#   database        = "gp_to_repo"
#   username        = data.aws_ssm_parameter.db-username.value
#   password        = data.aws_ssm_parameter.db-password.value
#   sslmode         = "require"
#   connect_timeout = 15
# }
