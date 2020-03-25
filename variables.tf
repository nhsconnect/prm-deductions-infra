variable "region" {
  type = string
  default = "eu-west-2"
}

variable "environment" {
  type = string
}

variable "my_ip" {
  default = "127.0.0.1"
}

variable "deductions_public_component_name" {
  type = string
}

variable "deductions_private_component_name" {
  type = string
}

variable "deductions_core_component_name" {
  type = string
}

variable "deductions_public_cidr" {
  type = string
}

variable "deductions_public_public_subnets" {
  type = list
}

variable "deductions_public_private_subnets" {
  type = list
}

variable "deductions_public_azs" {
  type = list
}

variable "deductions_private_cidr" {
  type = string
}

variable "deductions_private_public_subnets" {
  type = list
}

variable "deductions_private_private_subnets" {
  type = list
}

variable "deductions_private_azs" {
  type = list
}

variable "deductions_core_cidr" {
  type = string
}

variable "deductions_core_public_subnets" {
  type = list
}

variable "deductions_core_private_subnets" {
  type = list
}

variable "deductions_core_database_subnets" {
  type = list
}

variable "deductions_core_azs" {
  type = list
}

variable "mhs_cidr" {}

# deductions-public mq variables
variable "broker_name" {
  type = string
}

variable "mq_deployment_mode" {
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

variable "engine_type" {
  type        = string
  default     = "ActiveMQ"
  description = "The type of broker engine. Currently, Amazon MQ supports only ActiveMQ"
}

variable "engine_version" {
  type        = string
  default     = "5.15.0"
  description = "The version of the broker engine. Currently, Amazon MQ supports only 5.15.0 or 5.15.6."
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
