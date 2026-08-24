variable "azure_resource_prefix" {
  description = "Standard resource prefix. Usually s189t01 (test) or s189p01 (production)"
}
variable "config_short" {
  description = "Short name of the environment configuration, e.g. dv, st, pd..."
}
variable "service_short" {
  description = "Short name to identify the service. Up to 6 charcters."
}

variable "enable_application_insights" {
  type        = bool
  description = "Boolean to enable application insights resources"
  default     = false
}

variable "availability_tests" {
  type        = map(any)
  description = "Configuration for application insights availability tests"
  default     = {}
}

variable "action_group_email_receivers" {
  type        = list(any)
  description = "List of email receivers for metric alert action group"
  default     = []
}

variable "action_group_sms_receivers" {
  type        = list(any)
  description = "List of SMS receivers for metric alert action group"
  default     = []
}

variable "monitoring_tags" {
  type        = map(any)
  description = "tags for Azure monitoring resources"
  default     = {}
}