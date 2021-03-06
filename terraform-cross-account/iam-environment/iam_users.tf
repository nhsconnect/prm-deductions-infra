data "aws_iam_policy_document" "trust_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_ssm_parameter.ci_account_id.value}:role/NHSDAdminRole"]
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

data "aws_ssm_parameter" "ci_account_id" {
  name = "/repo/ci/user-input/external/aws-account-id"
}