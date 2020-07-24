provider cloudfoundry {
    api_url = "https://api.london.cloud.service.gov.uk"
    user = var.cf_user
    password = var.cf_password
}

terraform {
  required_version = ">= 0.12.28"

  backend s3 {
    bucket  = "terraform-state-govuk-paas"
    workspace_key_prefix = "env"
    key     = "terraform-paas.tfstate" # When using workspaces: [dev, review, staging, production] this changes to 'env/{workspace}/terraform-paas.tfstate'
    region  = "eu-west-2"
    encrypt = "true"
  }
}
