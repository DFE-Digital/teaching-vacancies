terraform {
  required_version = "~> 0.15.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.28.0"
    }
  }
}
