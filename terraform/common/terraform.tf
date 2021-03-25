provider "aws" {
  region = var.region
}

terraform {

  backend "s3" {
    bucket  = "530003481352-terraform-state"
    key     = "production/common.tfstate" # Grouping under production, as to deploy these resources requires production/Administrator permissions
    region  = "eu-west-2"
    encrypt = "true"
  }
}


module "domains" {
  source = "./modules/domains"

  primary_zone_name   = local.primary_zone_name
  secondary_zone_name = local.secondary_zone_name

}
