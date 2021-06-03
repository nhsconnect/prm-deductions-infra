module "ci_roles" {
  source = "./iam-ci"
  count = var.provision_ci_account ? 1 : 0
}

module "environment_roles" {
  source = "./iam-environment"
  count = var.provision_ci_account ? 0 : 1
}

