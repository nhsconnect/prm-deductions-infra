environment = "dev"
region      = "eu-west-2"
repo_name   = "prm-deductions-infra"

deductions_private_component_name = "deductions-private"
deductions_core_component_name    = "deductions-core"

gocd_cidr = "10.1.0.0/16"

mhs_cidr_newbits=8

deductions_private_cidr              = "10.20.0.0/16"
deductions_private_public_subnets    = ["10.20.101.0/24", "10.20.102.0/24"]
deductions_private_private_subnets   = ["10.20.1.0/24", "10.20.2.0/24"]
deductions_private_database_subnets  = ["10.20.111.0/24", "10.20.112.0/24"]
deductions_private_azs               = ["eu-west-2a", "eu-west-2b"]
deductions_private_vpn_client_subnet = "10.233.232.0/22"

deductions_core_cidr             = "10.25.0.0/16"
deductions_core_private_subnets  = ["10.25.1.0/24", "10.25.2.0/24"]
deductions_core_database_subnets = ["10.25.111.0/24", "10.25.112.0/24"]
deductions_core_azs              = ["eu-west-2a", "eu-west-2b"]

broker_name                    = "deductor-amq-broker-dev"
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
test_harness_mhs_cluster_domain_name = "test-harness-mhs.patient-deductions.nhs.uk"
mhs_vpc_cidr_block = "10.34.0.0/16" # Must not conflict with other networks
mhs_vpc_additional_cidr_block = ""
mhs_repo_public_subnets_inbound   = ["10.34.112.0/22", "10.34.116.0/22", "10.34.120.0/22"]
mhs_repo_public_subnets_outbound = ["10.34.100.0/22", "10.34.104.0/22", "10.34.108.0/22"]
mhs_repo_private_subnets = ["10.34.0.0/19", "10.34.32.0/19", "10.34.64.0/19"]
mhs_test_harness_public_subnets_inbound = ["10.34.232.0/22", "10.34.236.0/22", "10.34.240.0/22"]
mhs_test_harness_public_subnets_outbound = ["10.34.244.0/22", "10.34.248.0/22", "10.34.252.0/22"]
mhs_test_harness_private_subnets = ["10.34.128.0/19", "10.34.160.0/19", "10.34.192.0/19"]
mhs_repo_opentest_subnet = "10.34.96.0/20"
mhs_test_harness_opentest_subnet = "10.34.224.0/21"

spine_cidr_block = "192.168.128.0/24"

deploy_mhs_test_harness = true
deploy_opentest = true
deploy_hscn = false
deploy_cross_account_vpc_peering = true

dns_forward_zone = "opentest.hscic.gov.uk"
dns_hscn_forward_server_1 = "192.168.128.30"
dns_hscn_forward_server_2 = "192.168.128.30"

inbound_sig_ips=[]
deploy_mhs_nacl = false

grant_access_to_queues_through_vpn = true
