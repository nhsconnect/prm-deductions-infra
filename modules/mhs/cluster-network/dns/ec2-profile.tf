data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "dns-server" {
  name               = "mhs-${var.environment}-${var.cluster_name}-dns-server"
  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
  tags = {
    Environment = var.environment
    CreatedBy = var.repo_name
  }
}

resource "aws_iam_role_policy_attachment" "ecr_read_attach" {
  role       = aws_iam_role.dns-server.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "dns-server" {
  name = aws_iam_role.dns-server.name
  role = aws_iam_role.dns-server.name
}
