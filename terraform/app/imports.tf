import {
  for_each = var.app_environment == "production" ? [1] : null
  to       = module.application_insights[0].azurerm_application_insights.application_insights[0]
  id       = "/subscriptions/3c033a0c-7a1c-4653-93cb-0f2a9f57a391/resourceGroups/s189p01-tv-pd-rg/providers/Microsoft.Insights/components/s189p01-tv-pd-ai"
}

import {
  for_each = var.app_environment == "production" ? [1] : null
  to       = module.application_insights[0].azurerm_application_insights_standard_web_test.availability_test["500 error"]
  id       = "/subscriptions/3c033a0c-7a1c-4653-93cb-0f2a9f57a391/resourceGroups/s189p01-tv-pd-rg/providers/Microsoft.Insights/webTests/teaching vacancies - 500 error-s189p01-tv-pd-ai"
}

import {
  for_each = var.app_environment == "production" ? [1] : null
  to       = module.application_insights[0].azurerm_application_insights_standard_web_test.availability_test["check"]
  id       = "/subscriptions/3c033a0c-7a1c-4653-93cb-0f2a9f57a391/resourceGroups/s189p01-tv-pd-rg/providers/Microsoft.Insights/webTests/teaching vacancies check-s189p01-tv-pd-ai"
}

import {
  for_each = var.app_environment == "production" ? [1] : null
  to       = module.application_insights[0].azurerm_application_insights_standard_web_test.availability_test["homepage string"]
  id       = "/subscriptions/3c033a0c-7a1c-4653-93cb-0f2a9f57a391/resourceGroups/s189p01-tv-pd-rg/providers/Microsoft.Insights/webTests/teaching vacancies - homepage string-s189p01-tv-pd-ai"
}

import {
  for_each = var.app_environment == "production" ? [1] : null
  to       = module.application_insights[0].azurerm_monitor_action_group.action_group[0]
  id       = "/subscriptions/3C033A0C-7A1C-4653-93CB-0F2A9F57A391/resourceGroups/s189p01-tv-pd-rg/providers/Microsoft.Insights/actionGroups/s189p01-tv-pd-act-grp"
}

import {
  for_each = var.app_environment == "production" ? [1] : null
  to       = module.application_insights[0].azurerm_monitor_metric_alert.metric_alert["500 error"]
  id       = "/subscriptions/3c033a0c-7a1c-4653-93cb-0f2a9f57a391/resourceGroups/s189p01-tv-pd-rg/providers/Microsoft.Insights/metricAlerts/teaching vacancies - 500 error-s189p01-tv-pd-ai"
}

import {
  for_each = var.app_environment == "production" ? [1] : null
  to       = module.application_insights[0].azurerm_monitor_metric_alert.metric_alert["check"]
  id       = "/subscriptions/3c033a0c-7a1c-4653-93cb-0f2a9f57a391/resourceGroups/s189p01-tv-pd-rg/providers/Microsoft.Insights/metricAlerts/teaching vacancies check-s189p01-tv-pd-ai"
}

import {
  for_each = var.app_environment == "production" ? [1] : null
  to       = module.application_insights[0].azurerm_monitor_metric_alert.metric_alert["homepage string"]
  id       = "/subscriptions/3c033a0c-7a1c-4653-93cb-0f2a9f57a391/resourceGroups/s189p01-tv-pd-rg/providers/Microsoft.Insights/metricAlerts/teaching vacancies - homepage string-s189p01-tv-pd-ai"
}