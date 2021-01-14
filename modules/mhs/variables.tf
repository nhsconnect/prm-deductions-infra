variable "environment" {
  type = string
  description = "An ID used to identify the environment being deployed by this configuration. As this is used as a prefix for the names of most resources this should be kept to 20 characters or less."
}

variable "mhs_vpc_cidr_block" {
  type = string
  description = "The CIDR block to use for the MHS VPC that is created. Should be a /16 block. Note that this cidr block must not overlap with the cidr blocks of the VPCs that the MHS VPC is to be peered with."
}

variable "repo_name" {
  type = string
  default = "prm-deductions-infra"
}

variable "cidr_newbits" {
  description = "Defines the size of the subnets"
}

variable "deductions_private_cidr" {}
variable "deploy_mhs_test_harness" {}
variable "deductions_private_vpc_peering_connection_id" {}