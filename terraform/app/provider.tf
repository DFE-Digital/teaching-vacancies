provider "aws" {
  region = var.region
}

# The two aliases below are passed to the Cloudfront module
# Certificates for Cloudfront must be in us_east_1 region

provider "aws" {
  alias  = "default"
  region = var.region
}

provider "aws" {
  alias  = "aws_us_east_1"
  region = "us-east-1"
}
