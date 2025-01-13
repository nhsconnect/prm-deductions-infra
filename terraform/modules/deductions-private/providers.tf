terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.1"
      configuration_aliases = [ aws.ci ]
    }
  }
}