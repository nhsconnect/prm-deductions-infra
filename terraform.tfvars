environment                         = "dev"
region                              = "eu-west-2"


deductions_public_component_name    = "deductions-public"
deductions_public_cidr              = "10.40.0.0/16"
deductions_public_public_subnets    = ["10.40.1.0/24", "10.40.2.0/24"]
deductions_public_private_subnets   = ["10.40.101.0/24", "10.40.102.0/24"]
deductions_public_azs               = ["eu-west-2a", "eu-west-2b"]

deductions_public_create_bastion    = false



