provider "aws" {
  profile   = "default"
  version   = "~> 2.27"
  region    = "${var.region}"
}

terraform{
      backend "s3" {
        bucket  = "prm-327778747031-terraform-states"
        key     = "gpportal/terraform.tfstate"
        region  = "eu-west-2"
        encrypt = true
    }
}

module "deductions-public" {
    source              = "./modules/deductions-public/"
    environment         = "${var.environment}"
    component_name      = "${var.deductions_public_component_name}"
    cidr                = "${var.deductions_public_cidr}"

    public_subnets      = "${var.deductions_public_public_subnets}"
    private_subnets     = "${var.deductions_public_private_subnets}"
    azs                 = "${var.deductions_public_azs}"

    create_bastion      = "${var.deductions_public_create_bastion}"
}