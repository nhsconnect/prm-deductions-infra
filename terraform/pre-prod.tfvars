environment = "pre-prod"
region      = "eu-west-2"
repo_name   = "prm-deductions-infra"

deductions_private_component_name = "deductions-private"
deductions_core_component_name    = "deductions-core"

gocd_cidr = "10.1.0.0/16"

deductions_private_cidr             = "10.22.0.0/16"
deductions_core_cidr             = "10.27.0.0/16"

deductions_private_public_subnets   = ["10.22.101.0/24", "10.22.102.0/24"]
deductions_private_private_subnets  = ["10.22.1.0/24", "10.22.2.0/24"]
deductions_private_database_subnets = ["10.22.111.0/24", "10.22.112.0/24"]
deductions_private_azs              = ["eu-west-2b", "eu-west-2a"]
deductions_private_vpn_client_subnet = "10.233.200.0/22"

deductions_core_private_subnets  = ["10.27.1.0/24", "10.27.2.0/24"]
deductions_core_database_subnets = ["10.27.111.0/24", "10.27.112.0/24"]
deductions_core_azs              = ["eu-west-2b", "eu-west-2a"]

mhs_cidr_newbits=8

broker_name                    = "deductor-amq-broker-pre-prod"
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
state_db_allocated_storage = "20"
state_db_engine_version    = "11.5"
state_db_instance_class    = "db.t2.small"

repo_mhs_cluster_domain_name = "mhs.patient-deductions.nhs.uk"

mhs_vpc_cidr_block = "10.36.0.0/16"
mhs_vpc_additional_cidr_block = ""
mhs_repo_public_subnets  = ["10.36.112.0/22", "10.36.116.0/22", "10.36.120.0/22"]
mhs_repo_private_subnets = ["10.36.128.0/22", "10.36.132.0/22", "10.36.136.0/22"]
mhs_test_harness_public_subnets = []
mhs_test_harness_private_subnets = []
mhs_repo_opentest_subnet = ""
mhs_test_harness_opentest_subnet = ""

deploy_mhs_test_harness = false
deploy_opentest = false
deploy_hscn = false
deploy_cross_account_vpc_peering = true

dns_forward_zone = "ncrs.nhs.uk"
dns_hscn_forward_server_1 = "192.168.128.30" // TODO: double-check the values
dns_hscn_forward_server_2 = "192.168.128.30" // TODO: double-check the values

inbound_sig_ips = ["3.11.206.30/32", "3.8.223.81/32", "35.178.32.211/32","3.11.177.31/32","35.177.15.89/32","3.11.199.83/32","18.132.113.121/32","18.132.31.159/32","35.178.64.126/32"]
deploy_mhs_nacl = true

grant_access_to_queues_through_vpn = false

