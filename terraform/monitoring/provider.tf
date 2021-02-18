provider "cloudfoundry" {
  store_tokens_path = "./tokens"
  api_url           = local.paas_api_url
  user              = var.paas_user
  password          = var.paas_password
  sso_passcode      = var.paas_sso_passcode
}

provider "aws" {
  region = local.aws_region
}
