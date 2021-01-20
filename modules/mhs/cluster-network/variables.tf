variable "environment" {
  description = "An ID used to identify the environment being deployed by this configuration. As this is used as a prefix for the names of most resources this should be kept to 20 characters or less."
}

variable "region" {
  type    = string
  default = "eu-west-2"
}

variable "repo_name" {
  default = "prm-deductions-infra"
}

variable "mhs_vpc_id" {}
variable "cluster_name" {}
variable "deductions_private_cidr" {}
variable "deductions_private_vpc_peering_connection_id" {}
variable "deploy_opentest" {}
variable "mhs_nat_gateway_id" {}
variable "mhs_subnets" {}
variable "opentest_cidr_block" {}
variable "mhs_vpc_cidr_block" {}

variable "dns_forward_zone" {}
variable "dns_hscn_forward_server_1" {}
variable "dns_hscn_forward_server_2" {}
variable "unbound_image_version" {}