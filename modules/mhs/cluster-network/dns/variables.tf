variable "dns_global_forward_server" {}
variable "dns_forward_zone" {}
variable "dns_hscn_forward_server_1" {}
variable "dns_hscn_forward_server_2" {}
variable "ecr_address" {}
variable "unbound_image_version" {}
variable "subnet_ids" {}
variable "mhs_vpc_id" {}
variable "allowed_cidr" {}
variable "environment" {}
variable "repo_name" {
  type = string
  default = "prm-mhs-infra"
}
variable "cluster_name" {}
