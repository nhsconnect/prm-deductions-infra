terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.84.0"
      configuration_aliases = [ aws.ci ]
    }
  }
}