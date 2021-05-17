variable "environment" {
  type = string
  description = "An ID used to identify the environment being deployed by this configuration. As this is used as a prefix for the names of most resources this should be kept to 20 characters or less."
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "mhs_vpc_cidr_block" {
  type = string
  description = "The CIDR block to use for the MHS VPC that is created. Should be a /16 block. Note that this cidr block must not overlap with the cidr blocks of the VPCs that the MHS VPC is to be peered with."
}

variable "spine_cidr_block" {}

variable "repo_name" {
  type = string
  default = "prm-deductions-infra"
}

variable "deductions_private_cidr" {}
variable "deploy_opentest" {}
variable "deploy_public_subnet" {}

variable "dns_forward_zone" {}
variable "dns_hscn_forward_server_1" {}
variable "dns_hscn_forward_server_2" {}
variable "unbound_image_version" {}
variable "mhs_private_cidr_blocks" {}
variable "internet_private_cidr_block" {}
variable "deductions_private_vpc_id" {}
variable "cluster_name" {}
variable "mhs_public_cidr_block" {}
variable "mhs_cluster_domain_name" {}
variable "hscn_gateway_id" {}
variable "transit_gateway_id" {}
variable "gocd_cidr" {}