module "ci_roles" {
  source = "./iam-ci"
  count = var.provision_ci_account ? 1 : 0
}

module "environment_roles" {
  source = "./iam-environment"
  count = var.provision_ci_account ? 0 : 1
}

# pipeline:
# create RepoAdmin in dev
# create in test,....
# create in CI

# In dev account
# RepoAdmin allowing specific users to assume the role OR arn:aws:iam::327778747031:role/NHSDAdminRole
# Principal: "arn:aws:iam::327778747031:role/NHSDAdminRole"

# in CI account:
# RepoAdmin allow dev/RepoAdmin to assume the role. so that terraform running dev/test/etc can go back to CI to modify the resources in CI account.
# Principal: dev-account-id / RepoAdmin

