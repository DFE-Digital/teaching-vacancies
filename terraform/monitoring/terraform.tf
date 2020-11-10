/*
Store infrastructure state in a remote store (instead of local machine):
https://www.terraform.io/docs/state/purpose.html
*/
terraform {

  backend "s3" {
    bucket  = "terraform-state-002"
    key     = "tvs/terraform-monitoring.tfstate" # When using workspaces this changes to ':env/{terraform.workspace}/tvs/terraform.tfstate'
    region  = "eu-west-2"
    encrypt = "true"
  }
}
