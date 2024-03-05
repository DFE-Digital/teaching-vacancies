module "statuscake" {
  count  = var.enable_monitoring ? 1 : 0
  source = "./vendor/modules/aks//monitoring/statuscake"

  uptime_urls = compact(flatten([[
    for alert in values(var.statuscake_alerts) :
    alert.website_url if alert.website_url != null
  ], var.external_url != null ? [var.external_url] : []]))

  ssl_urls = var.external_url != null ? compact([var.external_url]) : []

  contact_groups = toset(flatten([
    for alert in values(var.statuscake_alerts) :
    alert.contact_group if alert.contact_group != null
  ]))
}
