module "ci_roles" {
  source = "./iam-ci"
  count = var.provision_ci_account ? 1 : 0
}

module "environment_roles" {
  source = "./iam-environment"
  count = var.provision_ci_account ? 0 : 1
  provision_strict_iam_roles = var.provision_strict_iam_roles
}

