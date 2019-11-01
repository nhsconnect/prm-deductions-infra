variable "region" {
  type = "string"
  default = "eu-west-2"
}

variable "environment" {
  type = "string"
}

variable "deductions_public_component_name" {
  type = "string"
}

variable "deductions_public_cidr" {
  type = "string"
}

variable "deductions_public_public_subnets" {
  type = "list"
}

variable "deductions_public_private_subnets" {
  type = "list"
}

variable "deductions_public_azs" {
  type = "list"
}

variable "deductions_public_create_bastion" {
  type = bool
}