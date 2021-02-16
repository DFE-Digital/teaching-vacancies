terraform {
  required_version = ">= 0.13.0"
  required_providers {
    aws = {
      source  = "-/aws"
      version = ">= 3.8.0"
    }
    template = {
      source  = "hashicorp/template"
      version = ">= 2.2.0"
    }
  }
}
