variable "region" {
  type = string
  default = "eu-west-2"
}

variable "environment" {
  type = string
}

variable "component_name" {
  type = string
}

variable "allowed_public_ips" {}

variable "cidr" {
  type = string
}

variable "public_subnets" {
  type = list
}

variable "private_subnets" {
  type = list
}

variable "azs" {
  type = list
}

variable "create_bastion" {
  type = bool
}
