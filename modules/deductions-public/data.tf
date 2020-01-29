data "aws_ssm_parameter" "deductions_private_bastion" {
    name = "/NHS/${var.environment}-${data.aws_caller_identity.current.account_id}/tf/deductions_private_bastion"
}

data "aws_caller_identity" "current" {}
