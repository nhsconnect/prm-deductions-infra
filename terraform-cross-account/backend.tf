provider "aws" {
  profile = "default"
  version = "~> 3.0"
  region  = var.region
}

terraform {
  backend "s3" {
    encrypt = true
  }
}
