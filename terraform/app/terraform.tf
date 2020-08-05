provider aws {
  region  = var.region
  version = "~> 2.70.0"
}

/*
For username / password authentication:
- user
- password
For SSO authentication
- sso_passcode
- store_tokens_path = /path/to/local/file
*/

provider cloudfoundry {
  api_url           = var.paas_api_url
  password          = var.paas_password != "" ? var.paas_password : null
  sso_passcode      = var.paas_sso_passcode != "" ? var.paas_sso_passcode : null
  store_tokens_path = "./tokens"
  user              = var.paas_user != "" ? var.paas_user : null
  version           = "~> 0.12"
}

provider statuscake {
  username = var.statuscake_username
  apikey   = var.statuscake_apikey
  version  = "~> 1.0.0"
}

provider template {
  version = "~> 2.1.2"
}

/*
Store infrastructure state in a remote store (instead of local machine):
https://www.terraform.io/docs/state/purpose.html
*/
terraform {
  required_version = ">= 0.12.6"

  backend "s3" {
    bucket  = "terraform-state-002"
    key     = "tvs/terraform.tfstate" # When using workspaces this changes to ':env/{terraform.workspace}/tvs/terraform.tfstate'
    region  = "eu-west-2"
    encrypt = "true"
  }
}

module cloudfront {
  source = "./modules/cloudfront"

  environment                   = terraform.workspace
  project_name                  = var.project_name
  cloudfront_origin_domain_name = var.cloudfront_origin_domain_name
  cloudfront_aliases            = var.cloudfront_aliases
  cloudfront_certificate_arn    = var.cloudfront_certificate_arn
  offline_bucket_domain_name    = var.offline_bucket_domain_name
  offline_bucket_origin_path    = var.offline_bucket_origin_path
  domain                        = var.domain
}

module cloudwatch {
  source = "./modules/cloudwatch"

  environment       = terraform.workspace
  project_name      = var.project_name
  slack_hook_url    = var.cloudwatch_slack_hook_url
  slack_channel     = var.cloudwatch_slack_channel
  ops_genie_api_key = var.cloudwatch_ops_genie_api_key
}

module paas {
  source = "./modules/paas"

  environment           = terraform.workspace
  project_name          = var.project_name
  postgres_service_plan = var.paas_postgres_service_plan
  space_name            = var.paas_space_name

}

module statuscake {
  source = "./modules/statuscake"

  environment       = terraform.workspace
  project_name      = var.project_name
  statuscake_alerts = var.statuscake_alerts
}
