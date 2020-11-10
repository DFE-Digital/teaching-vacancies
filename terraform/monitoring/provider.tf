provider cloudfoundry {
  store_tokens_path = "./tokens"
  api_url           = local.paas_api_url
  user              = var.paas_username != "" ? var.paas_username : null
  password          = var.paas_password != "" ? var.paas_password : null
  sso_passcode      = var.paas_sso_passcode != "" ? var.paas_sso_passcode : null
}
