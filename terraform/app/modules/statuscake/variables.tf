variable "environment" {
}

variable "service_name" {
}

variable "statuscake_alerts" {
  description = "Define Statuscake alerts with the attributes below"
}

variable "statuscake_enable_basic_auth" {
  type    = bool
  default = false
}
