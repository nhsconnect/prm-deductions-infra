variable "region" {
  type = string
  default = "eu-west-2"
}

variable "environment" {
  type        = string
  default     = "dev"
}

variable "repo_name" {
  type = string
  default = "prm-deductions-infra"
}

variable "gocd_environment" {
  type        = string
  default     = "prod"
}

variable "component_name" {
  type        = string
  default     = "deductions-private"
}

variable "cidr" {}

variable "gocd_cidr" {}

variable "deductions_core_cidr" {}

variable "allowed_public_ips" {}

variable "public_subnets" {
  type = list
}

variable "private_subnets" {
  type = list
}

variable "database_subnets" {
  type = list
}

variable "azs" {
  type = list
}

variable "pds_deregistration_delay" {
  default = 15
}

# deductions-public mq variables
variable "broker_name" {
  type = string
}

variable "apply_immediately" {
  type        = string
  default     = "false"
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
}

variable "auto_minor_version_upgrade" {
  type        = string
  default     = "false"
  description = "Enables automatic upgrades to new minor versions for brokers, as Apache releases the versions"
}

variable "deployment_mode" {
  type        = string
  default     = "ACTIVE_STANDBY_MULTI_AZ"
  description = "The deployment mode of the broker. Supported: SINGLE_INSTANCE and ACTIVE_STANDBY_MULTI_AZ"
}

variable "mq_deployment_mode" {
  type = string
}

variable "engine_type" {
  type        = string
  default     = "ActiveMQ"
  description = "The type of broker engine. Currently, Amazon MQ supports only ActiveMQ"
}

variable "engine_version" {
  type        = string
  default     = "5.15.13"
  description = "The version of the broker engine."
}

variable "host_instance_type" {
  type        = string
  default     = "mq.t2.micro"
  description = "The broker's instance type. e.g. mq.t2.micro or mq.m4.large"
}

variable "general_log" {
  type        = string
  default     = "true"
  description = "Enables general logging via CloudWatch"
}

variable "audit_log" {
  type        = string
  default     = "true"
  description = "Enables audit logging. User management action made using JMX or the ActiveMQ Web Console is logged"
}

variable "maintenance_day_of_week" {
  type        = string
  default     = "SUNDAY"
  description = "The maintenance day of the week. e.g. MONDAY, TUESDAY, or WEDNESDAY"
}

variable "maintenance_time_of_day" {
  type        = string
  default     = "03:00"
  description = "The maintenance time, in 24-hour format. e.g. 02:00"
}

variable "maintenance_time_zone" {
  type        = string
  default     = "UTC"
  description = "The maintenance time zone, in either the Country/City format, or the UTC offset format. e.g. CET"
}

variable "mq_admin_user" {
  type        = string
  default     = ""
  description = "Admin username"
}

variable "mq_admin_password" {
  type        = string
  default     = ""
  description = "Admin password"
}

variable "mq_application_user" {
  type        = string
  default     = ""
  description = "Application username"
}

variable "mq_application_password" {
  type        = string
  default     = ""
  description = "Application password"
}

variable "mq_allow_public_console_access"{
  description = "Will create an NLB in two public subnets to provide internet access to the MQ admin console"
}

variable "private_zone_id" {
  description = "ID of patient-deductions.nhs.uk private zone"
}

variable "state_db_allocated_storage" {}
variable "state_db_engine_version" {}
variable "state_db_instance_class" {}

variable "vpn_client_subnet" {}

variable "core_private_vpc_peering_connection_id" {}
variable "mhs_vpc_cidr_block" {}
variable "mhs_vpc_peering_connection_id" {}