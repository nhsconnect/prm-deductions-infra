variable "region" {}
variable "environment" {}
variable "availability_zone" {}
variable "vpc_id" {}
variable "public_subnet_id" {}
variable "my_ip" {
  default = "127.0.0.1"
  description = "Additional IP to whitelist for provisioning"
}
