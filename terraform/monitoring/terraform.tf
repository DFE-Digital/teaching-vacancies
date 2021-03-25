/*
Store infrastructure state in a remote store (instead of local machine):
https://www.terraform.io/docs/state/purpose.html
*/
terraform {

  backend "s3" {
    bucket  = "530003481352-terraform-state"
    key     = "production/monitoring.tfstate" # Currently we only deploy a single production instance, monitoring all environments. We may want to deploy test monitoring instances in the future
    region  = "eu-west-2"
    encrypt = "true"
  }
}
