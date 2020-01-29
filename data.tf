
data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "inbound_ips" {
    name = "/NHS/dev-${data.aws_caller_identity.current.account_id}/tf/inbound_ips"
}

data "aws_ssm_parameter" "agent_ips" {
    name = "/NHS/deductions-${data.aws_caller_identity.current.account_id}/gocd-prod/agent_ips"
}

locals {
  agent_cidrs = [
    for ip in split(",", data.aws_ssm_parameter.agent_ips.value):
      "${ip}/32"
  ]
  # This local should be the only source of truth on what IPs are allowed to connect from the Internet
  allowed_public_ips = concat(
    split(",", data.aws_ssm_parameter.inbound_ips.value),
    local.agent_cidrs)
}
