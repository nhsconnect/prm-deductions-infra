terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.83.0"
      configuration_aliases = [ aws.ci ]
    }
  }
}