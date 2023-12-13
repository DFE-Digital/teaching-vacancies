terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      version               = "5.29.0"
      configuration_aliases = [aws.aws_us_east_1]
    }
  }
}
