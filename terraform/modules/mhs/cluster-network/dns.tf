module "dns" {
  source = "./dns"
  dns_global_forward_server = cidrhost(var.mhs_vpc_cidr_block, 2) # AWS DNS - second IP in the subnet
  dns_hscn_forward_server_1 = var.dns_hscn_forward_server_1
  dns_hscn_forward_server_2 = var.dns_hscn_forward_server_2
  dns_forward_zone          = var.dns_forward_zone
  environment = var.environment
  repo_name = var.repo_name
  subnet_ids = aws_subnet.mhs_subnet.*.id
  cluster_name = var.cluster_name
  mhs_vpc_id = var.mhs_vpc_id
  allowed_cidr = var.mhs_vpc_cidr_block
  ecr_address = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com" # created in prm-deductions-base-infra
  unbound_image_version = var.unbound_image_version
}