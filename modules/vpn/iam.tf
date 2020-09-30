data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vpn-server" {
  name               = "vpn-${var.environment}-server"
  path               = "/"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  tags = {
    CreatedBy   = var.repo_name
    Environment = var.environment
  }
}

resource "aws_iam_instance_profile" "vpn-server" {
  name = "vpn-${var.environment}-server"
  role = aws_iam_role.vpn-server.name
}

resource "aws_cloudwatch_log_group" "vpn-server" {
  name              = "vpn-logs-${var.environment}-server"
  retention_in_days = 90
}

resource "aws_iam_policy" "cloudwatch_policy" {
    description = "Policy for VPN VM to access the logs"
    name        = "vpn-logs-${var.environment}-cloudwatch_policy"
    path        = "/"
    policy      = jsonencode(
            {
            Statement = [
                {
                    Action   = [
                        "logs:CreateLogStream",
                        "logs:PutLogEvents",
                        ]
                    Effect   = "Allow"
                    Resource = "*"
                    },
                ]
            Version   = "2012-10-17"
            }
        )
}

resource "aws_iam_role_policy_attachment" "cloudwatch-attach" {
    role       = aws_iam_role.vpn-server.name
    policy_arn = aws_iam_policy.cloudwatch_policy.arn
}
