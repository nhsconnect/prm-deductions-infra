
data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "agent_ips" {
    name = "/repo/prod/prm-gocd-infra/output/gocd-agent-ips"
}

locals {
  agent_cidrs = [
    for ip in split(",", data.aws_ssm_parameter.agent_ips.value):
      "${ip}/32"
  ]
  # This local should be the only source of truth on what IPs are allowed to connect from the Internet
  allowed_public_ips = local.agent_cidrs
}
