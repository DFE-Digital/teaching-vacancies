terraform {

  required_providers {
    aws = {
      source  = "-/aws"
      version = ">= 2.70.0"
    }
    template = {
      source = "hashicorp/template"
      version = ">= 2.0.0"
    }
  }
}
