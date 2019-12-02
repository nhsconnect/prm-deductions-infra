environment                         = "dev"
region                              = "eu-west-2"


deductions_public_component_name    = "deductions-public"
deductions_private_component_name   = "deductions-private"
deductions_core_component_name      = "deductions-core"

deductions_public_cidr              = "10.40.0.0/16"
deductions_public_public_subnets    = ["10.40.1.0/24", "10.40.2.0/24"]
deductions_public_private_subnets   = ["10.40.101.0/24", "10.40.102.0/24"]
deductions_public_azs               = ["eu-west-2a", "eu-west-2b"]

deductions_public_create_bastion    = false

broker_name                         = "deductor-amq-broker-dev"
deployment_mode                     = "ACTIVE_STANDBY_MULTI_AZ"
engine_type                         = "ActiveMQ"
engine_version                      = "5.15.9"
host_instance_type                  = "mq.t2.micro"
auto_minor_version_upgrade          = "true"
apply_immediately                   = "true"
general_log                         = "true"
audit_log                           = "true"
maintenance_day_of_week             = "SUNDAY"
maintenance_time_of_day             = "03:00"
maintenance_time_zone               = "GMT"
mq_allow_public_console_access      = true



