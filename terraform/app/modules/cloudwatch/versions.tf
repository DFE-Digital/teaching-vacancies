terraform {
  required_version = ">= 0.13.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.28.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.0.0"
    }
  }
}
