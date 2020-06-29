variable "project_name" {
  description = "This name will be used to identify all AWS resources. The workspace name will be suffixed. Alphanumeric characters only due to RDS."
}

variable "region" {
  default = "eu-west-2"
}

# CloudFront
variable "cloudfront_certificate_arn" {
  description = "Create and verify a certificate through AWS Certificate Manager to acquire this"
}

variable "cloudfront_aliases" {
  description = "Match this value to the alias associated with the cloudfront_certificate_arn, eg. tvs.staging.dxw.net"
  type        = "list"
}

variable "offline_bucket_domain_name" {}
variable "offline_bucket_origin_path" {}

variable "domain" {}

variable "cloudfront_origin_domain_name" {
  default = ""
}

# Cloudwatch
variable "cloudwatch_slack_hook_url" {
  description = "The slack hook that cloudwatch alarms are sent to"
}

variable "cloudwatch_slack_channel" {
  description = "The slack channel that cloudwatch alarms are sent to"
}

variable "cloudwatch_ops_genie_api_key" {
  description = "The ops genie api key for sending alerts to ops genie"
}
