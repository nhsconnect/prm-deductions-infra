variable "region" {}
variable "environment" {}
variable "availability_zone" {}
variable "vpc_id" {}
variable "public_subnet_id" {}
variable "my_ip" {
  default = "127.0.0.1"
  description = "Additional IP to whitelist for provisioning"
}
variable "vpn_port" {
  default = 443
}
variable "vpn_ami_id" {
  default = "ami-04cc79dd5df3bffca"
}

variable "repo_name" {
  type = string
  default = "prm-deductions-infra"
}
