environment                         = "test"
region                              = "eu-west-2"


deductions_public_component_name    = "deductions-public"
deductions_private_component_name   = "deductions-private"
deductions_core_component_name      = "deductions-core"

mhs_cidr                            = "10.239.68.128/25"

deductions_public_cidr              = "10.41.0.0/16"
deductions_public_public_subnets    = ["10.41.101.0/24", "10.41.102.0/24"]
deductions_public_private_subnets   = ["10.41.1.0/24", "10.41.2.0/24"]
deductions_public_azs               = ["eu-west-2b", "eu-west-2a"]

deductions_private_cidr              = "10.21.0.0/16"
deductions_private_public_subnets    = ["10.21.101.0/24", "10.21.102.0/24"]
deductions_private_private_subnets   = ["10.21.1.0/24", "10.21.2.0/24"]
deductions_private_azs               = ["eu-west-2b", "eu-west-2a"]

deductions_core_cidr              = "10.26.0.0/16"
deductions_core_public_subnets    = ["10.26.101.0/24", "10.26.102.0/24"]
deductions_core_private_subnets   = ["10.26.1.0/24", "10.26.2.0/24"]
deductions_core_database_subnets  = ["10.26.111.0/24", "10.26.112.0/24"]
deductions_core_azs               = ["eu-west-2b", "eu-west-2a"]

deductions_public_create_bastion    = false

broker_name                         = "deductor-amq-broker-test"
deployment_mode                     = "ACTIVE_STANDBY_MULTI_AZ"
engine_type                         = "ActiveMQ"
engine_version                      = "5.15.10"
host_instance_type                  = "mq.t2.micro"
auto_minor_version_upgrade          = "true"
apply_immediately                   = "true"
general_log                         = "true"
audit_log                           = "true"
maintenance_day_of_week             = "SUNDAY"
maintenance_time_of_day             = "03:00"
maintenance_time_zone               = "GMT"
mq_allow_public_console_access      = true
