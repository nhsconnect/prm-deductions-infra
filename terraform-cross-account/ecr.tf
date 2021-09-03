resource "aws_ecr_repository" "gp-to-repo" {
  name = "deductions/gp-to-repo"
  image_tag_mutability = var.immutable_ecr_repositories ? "IMMUTABLE" : "MUTABLE"
  tags = {
    CreatedBy = var.repo_name
  }
}

resource "aws_ecr_repository" "repo-to-gp" {
  name = "deductions/repo-to-gp"
  image_tag_mutability = var.immutable_ecr_repositories ? "IMMUTABLE" : "MUTABLE"
  tags = {
    CreatedBy = var.repo_name
  }
}

resource "aws_ecr_repository" "gp2gp-adaptor" {
  name = "deductions/gp2gp-adaptor"
  image_tag_mutability = var.immutable_ecr_repositories ? "IMMUTABLE" : "MUTABLE"
  tags = {
    CreatedBy = var.repo_name
  }
}

resource "aws_ecr_repository" "gp2gp-message-handler" {
  name = "deductions/gp2gp-message-handler"
  image_tag_mutability = var.immutable_ecr_repositories ? "IMMUTABLE" : "MUTABLE"
  tags = {
    CreatedBy = var.repo_name
  }
}


resource "aws_ecr_repository" "ehr-repo" {
  name = "deductions/ehr-repo"
  image_tag_mutability = var.immutable_ecr_repositories ? "IMMUTABLE" : "MUTABLE"
  tags = {
    CreatedBy = var.repo_name
  }
}

resource "aws_ecr_repository" "mhs-inbound" {
  name = "mhs-inbound"
  image_tag_mutability = var.immutable_ecr_repositories ? "IMMUTABLE" : "MUTABLE"
  tags = {
    CreatedBy = var.repo_name
  }
}

resource "aws_ecr_repository" "mhs-outbound" {
  name = "mhs-outbound"
  image_tag_mutability = var.immutable_ecr_repositories ? "IMMUTABLE" : "MUTABLE"
  tags = {
    CreatedBy = var.repo_name
  }
}

resource "aws_ecr_repository" "pds_adaptor" {
  name = "deductions/pds-adaptor"
  image_tag_mutability = var.immutable_ecr_repositories ? "IMMUTABLE" : "MUTABLE"
  tags = {
    CreatedBy = var.repo_name
  }
}