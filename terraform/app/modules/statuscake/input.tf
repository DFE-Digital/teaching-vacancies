variable "environment" {}
variable "project_name" {}
variable "statuscake_alerts" {
  description = "What will Statuscake alert on. A Terraform 0.11 map of 8 values - website_name, website_url, test_type, check_rate, contact_id, trigger_rate, custom_header, status_codes"
  type = "map"
}