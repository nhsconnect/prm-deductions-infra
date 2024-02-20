terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.76.1"
    }
    latest-aws = {
      source  = "hashicorp/aws"
      version = "5.37.0"
      alias   = "latest"
    }
  }
}