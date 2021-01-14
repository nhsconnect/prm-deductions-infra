variable "environment" {
  description = "An ID used to identify the environment being deployed by this configuration. As this is used as a prefix for the names of most resources this should be kept to 20 characters or less."
}

variable "mhs_vpc_cidr_block" {
  description = "The CIDR block to use for the MHS VPC that is created. Should be a /16 block. Note that this cidr block must not overlap with the cidr blocks of the VPCs that the MHS VPC is to be peered with."
}

variable "repo_name" {
  default = "prm-deductions-infra"
}

variable "cidr_newbits" {
  description = "Defines the size of the subnets"
}

variable "mhs_vpc_id" {}
variable "cluster_name" {}
variable "cidr_delta" {}
variable "deductions_private_cidr" {}
variable "deductions_private_vpc_peering_connection_id" {}
variable "deploy_opentest" {}