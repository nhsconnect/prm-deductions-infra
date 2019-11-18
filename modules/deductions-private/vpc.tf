module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = "${var.environment}-${var.component_name}-vpc"
    cidr = "10.20.0.0/16"

    azs             = ["eu-west-2a", "eu-west-2b"]
    private_subnets = ["10.20.1.0/24", "10.20.2.0/24"]
    public_subnets  = ["10.20.101.0/24", "10.20.102.0/24"]

    enable_vpn_gateway = false

    enable_nat_gateway = true
    single_nat_gateway = true
    one_nat_gateway_per_az = false
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
        Terraform = "true"
        Environment = "dev"
    }
}
