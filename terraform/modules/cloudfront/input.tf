variable "environment" {}
variable "project_name" {}
variable "cloudfront_origin_domain_name" {}

variable "cloudfront_aliases" {
  type = "list"
}

variable "cloudfront_certificate_arn" {}
variable "offline_bucket_domain_name" {}
variable "offline_bucket_origin_path" {}
