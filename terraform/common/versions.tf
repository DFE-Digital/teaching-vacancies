terraform {
  required_version = "~> 0.14.0"
  required_providers {
    aws = {
      source  = "-/aws"
      version = "~> 3.18.0"
    }
  }
}
