variable project_name {
  description = "This name will be used to identify all AWS resources. The workspace name will be suffixed. Alphanumeric characters only due to RDS."
}

variable region {
  default = "eu-west-2"
}

# CloudFront
variable cloudfront_certificate_arn {
  description = "Create and verify a certificate through AWS Certificate Manager to acquire this"
}

variable cloudfront_aliases {
  description = "Match this value to the alias associated with the cloudfront_certificate_arn, eg. tvs.staging.dxw.net"
  type        = list(string)
}

variable offline_bucket_domain_name {
}

variable offline_bucket_origin_path {
}

variable domain {
}

variable cloudfront_origin_domain_name {
  default = ""
}

# Cloudwatch
variable cloudwatch_slack_hook_url {
  description = "The slack hook that cloudwatch alarms are sent to"
}

variable cloudwatch_slack_channel {
  description = "The slack channel that cloudwatch alarms are sent to"
}

variable cloudwatch_ops_genie_api_key {
  description = "The ops genie api key for sending alerts to ops genie"
}

# Gov.UK PaaS
variable paas_api_url {
}

variable paas_password {
  default = ""
}

variable paas_postgres_service_plan {
  default = "tiny-unencrypted-11"
}

variable paas_space_name {
}

variable paas_sso_passcode {
  default = ""
}

variable paas_store_tokens_path {
  default = ""
}

variable paas_user {
  default = ""
}

# Statuscake
variable statuscake_username {
  description = "The Statuscake username"
}

variable statuscake_apikey {
  description = "The Statuscake API key"
}

variable statuscake_alerts {
  description = "Define Statuscake alerts with the attributes below"
  type = map(object({
    website_name  = string
    website_url   = string
    test_type     = string
    check_rate    = string
    contact_group = list(string)
    trigger_rate  = string
    custom_header = string
    status_codes  = string
  }))
  default = {}
}
