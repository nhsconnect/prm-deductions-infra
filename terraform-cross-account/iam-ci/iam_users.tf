data "aws_caller_identity" "ci_account" {}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_ssm_parameter.dev_account_id.value}:role/RepoAdmin",         # dev environment (in dev account)
        "arn:aws:iam::${data.aws_caller_identity.ci_account.account_id}:role/NHSDAdminRole",  # test environment (in ci account)
        "arn:aws:iam::${data.aws_ssm_parameter.pre_prod_account_id.value}:role/RepoAdmin",    # pre-prod environment (in pre-prod account)
        "arn:aws:iam::${data.aws_ssm_parameter.pre_prod_account_id.value}:role/BootstrapAdmin",    # pre-prod environment Bootstrap Admin (in pre-prod account)
        "arn:aws:iam::${data.aws_ssm_parameter.pre_prod_account_id.value}:role/RepoDeveloper",  # pre-prod environment RepoDeveloper (in pre-prod account)
        # more accounts will follow for other environments...
      ]
    }
  }
}

resource "aws_iam_role" "repo_admin" {
  name = "RepoAdmin"
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
}


resource "aws_iam_role_policy_attachment" "repo_admin" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role = aws_iam_role.repo_admin.name
}

data "aws_ssm_parameter" "dev_account_id" {
  name = "/repo/dev/user-input/external/aws-account-id"
}

data "aws_ssm_parameter" "pre_prod_account_id" {
  name = "/repo/pre-prod/user-input/external/aws-account-id"
}
