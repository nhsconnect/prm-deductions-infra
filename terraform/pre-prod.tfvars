environment = "test"
region      = "eu-west-2"
repo_name   = "prm-deductions-infra"

deductions_private_component_name = "deductions-private"
deductions_core_component_name    = "deductions-core"

gocd_cidr = "10.1.0.0/16"

deductions_private_cidr             = "10.22.0.0/16"
deductions_core_cidr             = "10.27.0.0/16"
mhs_vpc_cidr_block = "10.36.0.0/16"

deductions_private_public_subnets   = ["10.22.101.0/24", "10.22.102.0/24"]
deductions_private_private_subnets  = ["10.22.1.0/24", "10.22.2.0/24"]
deductions_private_database_subnets = ["10.22.111.0/24", "10.22.112.0/24"]
deductions_private_azs              = ["eu-west-2b", "eu-west-2a"]
deductions_private_vpn_client_subnet = "10.233.200.0/22"

deductions_core_public_subnets   = ["10.27.101.0/24", "10.27.102.0/24"]
deductions_core_private_subnets  = ["10.27.1.0/24", "10.27.2.0/24"]
deductions_core_database_subnets = ["10.27.111.0/24", "10.27.112.0/24"]
deductions_core_azs              = ["eu-west-2b", "eu-west-2a"]
