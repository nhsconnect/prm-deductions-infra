variable "region" {
  type = string
  default = "eu-west-2"
}

variable "environment" {
  type        = string
  default     = "dev"
}

variable "component_name" {
  type        = string
  default     = "deductions-core"
}

variable "ehr_deregistration_delay" {
  default = 30
}

variable "private_zone_id" {}

variable "cidr" {}

variable "allowed_cidr" {}

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
