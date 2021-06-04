terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.44.0"
      configuration_aliases = [ aws.ci ]
    }
  }
}