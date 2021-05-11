provider "cloudfoundry" {
  store_tokens_path = "./tokens"
  api_url           = local.paas_api_url
  user              = var.paas_sso_passcode == null ? local.secrets.cf_username : null
  password          = var.paas_sso_passcode == null ? local.secrets.cf_password : null
  sso_passcode      = var.paas_sso_passcode
}

provider "aws" {
  region = local.aws_region
}
