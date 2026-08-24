resource "azurerm_application_insights" "application_insights" {
  count               = var.enable_application_insights == true ? 1 : 0
  name                = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-ai"
  location            = "UK South"
  resource_group_name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
  application_type    = "web"
  sampling_percentage = 0

  tags = var.monitoring_tags
}

resource "azurerm_application_insights_standard_web_test" "availability_test" {
  for_each                = var.availability_tests
  name                    = "teaching vacancies ${var.availability_tests[each.key].name}-${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-ai"
  resource_group_name     = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
  location                = "UK South"
  application_insights_id = azurerm_application_insights.application_insights[0].id
  geo_locations           = var.availability_tests[each.key].geo_locations
  timeout                 = var.availability_tests[each.key].timeout
  enabled                 = true
  retry_enabled           = true

  request {
    url                              = var.availability_tests[each.key].url
    parse_dependent_requests_enabled = false
    follow_redirects_enabled         = false
  }

  validation_rules {
    ssl_check_enabled           = var.availability_tests[each.key].ssl_check_enabled == true ? true : false
    ssl_cert_remaining_lifetime = var.availability_tests[each.key].ssl_cert_remaining_lifetime != null ? var.availability_tests[each.key].ssl_cert_remaining_lifetime : null
    dynamic "content" {
      for_each = length(keys(var.availability_tests[each.key].content)) > 0 ? [var.availability_tests[each.key].content] : []
      content {
        content_match      = content.value.content_match
        ignore_case        = content.value.ignore_case
        pass_if_text_found = content.value.pass_if_text_found
      }
    }
  }

  tags = var.monitoring_tags
}

resource "azurerm_monitor_action_group" "action_group" {
  count               = var.enable_application_insights == true ? 1 : 0
  name                = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-act-grp"
  resource_group_name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
  short_name          = "${var.service_short}${var.config_short}-act-grp"

  dynamic "email_receiver" {
    for_each = var.action_group_email_receivers
    content {
      name                    = email_receiver.value.name
      email_address           = email_receiver.value.emailAddress
      use_common_alert_schema = true
    }
  }

  # action_group_email_receivers variable is stored as environment secret in Github and passed in via workflow. Secret should be stored as a list of JSON objects as below:
  # [{"name": "FirstName1 LastName1_-EmailAction-","emailAddress":"firstname1.lastname1@education.gov.uk"},{"name": "FirstName2 LastName2_-EmailAction-","emailAddress": "firstname2.lastname2@education.gov.uk"}]
  # Full existing config can be found by opening the JSON view of the resource in the Azure portal

  dynamic "sms_receiver" {
    for_each = var.action_group_sms_receivers
    content {
      name         = sms_receiver.value.name
      phone_number = sms_receiver.value.phoneNumber
      country_code = "44"
    }
  }

  # action_group_sms_receivers variable is stored as environment secret in Github and passed in via workflow. Secret should be stored as a list of JSON objects as below:
  # [{"name": "FirstName1 LastName1_-SMSAction-","phoneNumber": "1234567890"},{"name": "FirstName2 LastName2_-SMSAction-","phoneNumber": "0987654321"}]
  # Full existing config can be found by opening the JSON view of the resource in the Azure portal

  tags = var.monitoring_tags
}

resource "azurerm_monitor_metric_alert" "metric_alert" {
  for_each            = var.availability_tests
  name                = "teaching vacancies ${var.availability_tests[each.key].name}-${azurerm_application_insights.application_insights[0].name}"
  resource_group_name = "${var.azure_resource_prefix}-${var.service_short}-${var.config_short}-rg"
  scopes              = [azurerm_application_insights.application_insights[0].id, azurerm_application_insights_standard_web_test.availability_test[each.key].id]
  description         = "Automatically created alert rule for availability test \"teaching vacancies ${var.availability_tests[each.key].name}-${azurerm_application_insights.application_insights[0].name}\""
  severity            = 1
  auto_mitigate       = false

  application_insights_web_test_location_availability_criteria {
    web_test_id           = azurerm_application_insights_standard_web_test.availability_test[each.key].id
    component_id          = azurerm_application_insights.application_insights[0].id
    failed_location_count = 2
  }

  dynamic "action" {
    for_each = var.availability_tests[each.key].action_group ? [1] : []
    content {
      action_group_id    = azurerm_monitor_action_group.action_group[0].id
      webhook_properties = {}
    }
  }

  tags = merge(var.monitoring_tags, {
    "hidden-link:/subscriptions/3c033a0c-7a1c-4653-93cb-0f2a9f57a391/resourcegroups/s189p01-tv-pd-rg/providers/microsoft.insights/components/${azurerm_application_insights.application_insights[0].name}"                     = "Resource",
    "hidden-link:/subscriptions/3c033a0c-7a1c-4653-93cb-0f2a9f57a391/resourcegroups/s189p01-tv-pd-rg/providers/microsoft.insights/webtests/${azurerm_application_insights_standard_web_test.availability_test[each.key].name}" = "Resource"
  })
}

