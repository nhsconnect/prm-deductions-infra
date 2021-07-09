environment = "test"
region      = "eu-west-2"
repo_name   = "prm-deductions-infra"

deductions_private_component_name = "deductions-private"
deductions_core_component_name    = "deductions-core"

gocd_cidr = "10.1.0.0/16"

mhs_cidr_newbits=2

deductions_private_cidr             = "10.21.0.0/16"
deductions_private_public_subnets   = ["10.21.101.0/24", "10.21.102.0/24"]
deductions_private_private_subnets  = ["10.21.1.0/24", "10.21.2.0/24"]
deductions_private_database_subnets = ["10.21.111.0/24", "10.21.112.0/24"]
deductions_private_azs              = ["eu-west-2b", "eu-west-2a"]
deductions_private_vpn_client_subnet = "10.233.200.0/22"

deductions_core_cidr             = "10.26.0.0/16"
deductions_core_public_subnets   = ["10.26.101.0/24", "10.26.102.0/24"]
deductions_core_private_subnets  = ["10.26.1.0/24", "10.26.2.0/24"]
deductions_core_database_subnets = ["10.26.111.0/24", "10.26.112.0/24"]
deductions_core_azs              = ["eu-west-2b", "eu-west-2a"]

broker_name                    = "deductor-amq-broker-test"
deployment_mode                = "ACTIVE_STANDBY_MULTI_AZ"
mq_deployment_mode             = "SINGLE_INSTANCE"
engine_type                    = "ActiveMQ"
engine_version                 = "5.15.15"
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

mhs_vpc_cidr_block = "10.239.68.128/25" # This is pre-allocated by NHSD
mhs_vpc_additional_cidr_block = "10.239.68.0/25"
mhs_repo_public_subnets   = ["10.239.68.0/27", "10.239.68.32/27", "10.239.68.64/27"]
mhs_test_harness_public_subnets   = []

deploy_mhs_test_harness = false
deploy_opentest = false
deploy_hscn = true

deploy_cross_account_vpc_peering = false

dns_forward_zone = "ncrs.nhs.uk"
dns_hscn_forward_server_1 = "155.231.231.1"
dns_hscn_forward_server_2 = "155.231.231.2"
hscn_gateway_id = "vgw-0ed5add471169ed85"
repo_mhs_cluster_domain_name = "mhs.patient-deductions.nhs.uk"
inbound_sig_ips = ["3.11.206.30/32", "3.8.223.81/32", "35.178.32.211/32"]
deploy_mhs_nacl = true

