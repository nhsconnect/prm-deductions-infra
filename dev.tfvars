environment = "dev"
region      = "eu-west-2"
repo_name   = "prm-deductions-infra"


deductions_public_component_name  = "deductions-public"
deductions_private_component_name = "deductions-private"
deductions_core_component_name    = "deductions-core"

gocd_cidr = "10.1.0.0/16"

mhs_cidr_newbits=8

deductions_public_cidr            = "10.40.0.0/16"
deductions_public_public_subnets  = ["10.40.1.0/24", "10.40.2.0/24"]
deductions_public_private_subnets = ["10.40.101.0/24", "10.40.102.0/24"]
deductions_public_azs             = ["eu-west-2a", "eu-west-2b"]

deductions_private_cidr              = "10.20.0.0/16"
deductions_private_public_subnets    = ["10.20.101.0/24", "10.20.102.0/24"]
deductions_private_private_subnets   = ["10.20.1.0/24", "10.20.2.0/24"]
deductions_private_database_subnets  = ["10.20.111.0/24", "10.20.112.0/24"]
deductions_private_azs               = ["eu-west-2a", "eu-west-2b"]
deductions_private_vpn_client_subnet = "10.233.232.0/22"

deductions_core_cidr             = "10.25.0.0/16"
deductions_core_public_subnets   = ["10.25.101.0/24", "10.25.102.0/24"]
deductions_core_private_subnets  = ["10.25.1.0/24", "10.25.2.0/24"]
deductions_core_database_subnets = ["10.25.111.0/24", "10.25.112.0/24"]
deductions_core_azs              = ["eu-west-2a", "eu-west-2b"]

broker_name                    = "deductor-amq-broker-dev"
deployment_mode                = "ACTIVE_STANDBY_MULTI_AZ"
mq_deployment_mode             = "SINGLE_INSTANCE"
engine_type                    = "ActiveMQ"
engine_version                 = "5.15.14"
host_instance_type             = "mq.t2.micro"
auto_minor_version_upgrade     = "true"
apply_immediately              = "true"
general_log                    = "true"
audit_log                      = "true"
maintenance_day_of_week        = "SUNDAY"
maintenance_time_of_day        = "03:00"
maintenance_time_zone          = "GMT"
mq_allow_public_console_access = true

state_db_allocated_storage = "20"
state_db_engine_version    = "11.5"
state_db_instance_class    = "db.t2.small"

mhs_vpc_cidr_block = "10.34.0.0/16" # Must not conflict with other networks

deploy_mhs_test_harness = true