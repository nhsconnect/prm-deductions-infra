variable "region" {
  type = string
  default = "eu-west-2"
}

variable "environment" {
  type = string
  default     = "dev"
}

variable "component_name" {
  type    = string
  default = "deductions-public"
}

variable "cidr" {}

variable "allowed_public_ips" {}

variable "public_subnets" {
  type = list
}

variable "private_subnets" {
  type = list
}

variable "azs" {
  type = list
}