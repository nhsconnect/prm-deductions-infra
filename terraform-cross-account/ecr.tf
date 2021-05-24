resource "aws_ecr_repository" "gp-to-repo" {
  name = "deductions/gp-to-repo"
  tags = {
    CreatedBy = var.repo_name
  }
}

resource "aws_ecr_repository" "repo-to-gp" {
  name = "deductions/repo-to-gp"
  tags = {
    CreatedBy = var.repo_name
  }
}

resource "aws_ecr_repository" "gp2gp-adaptor" {
  name = "deductions/gp2gp-adaptor"
  tags = {
    CreatedBy = var.repo_name
  }
}

resource "aws_ecr_repository" "gp2gp-message-handler" {
  name = "deductions/gp2gp-message-handler"
  tags = {
    CreatedBy = var.repo_name
  }
}


resource "aws_ecr_repository" "ehr-repo" {
  name = "deductions/ehr-repo"
  tags = {
    CreatedBy = var.repo_name
  }
}

resource "aws_ecr_repository" "mhs-inbound" {
  name = "mhs-inbound"
  tags = {
    CreatedBy = var.repo_name
  }
}

resource "aws_ecr_repository" "mhs-outbound" {
  name = "mhs-outbound"
  tags = {
    CreatedBy = var.repo_name
  }
}

resource "aws_ecr_repository" "mhs-route" {
  name = "mhs-route"
  tags = {
    CreatedBy = var.repo_name
  }
}

resource "aws_ecr_repository" "mhs-unbound-dns" {
  name = "mhs-unbound-dns"
  tags = {
    CreatedBy = var.repo_name
  }
}
