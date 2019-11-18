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

module "deductions-private" {
    source              = "./modules/deductions-private/"
    environment         = "${var.environment}"
    component_name      = "${var.deductions_private_component_name}"

    broker_name                         = "${var.broker_name}"
    deployment_mode                     = "${var.deployment_mode}"
    engine_type                         = "${var.engine_type}"
    engine_version                      = "${var.engine_version}"
    host_instance_type                  = "${var.host_instance_type}"
    auto_minor_version_upgrade          = "${var.auto_minor_version_upgrade}"
    apply_immediately                   = "${var.apply_immediately}"
    general_log                         = "${var.general_log}"
    audit_log                           = "${var.audit_log}"
    maintenance_day_of_week             = "${var.maintenance_day_of_week}"
    maintenance_time_of_day             = "${var.maintenance_time_of_day}"
    maintenance_time_zone               = "${var.maintenance_time_zone}"
    mq_allow_public_console_access      = "${var.mq_allow_public_console_access}"
}