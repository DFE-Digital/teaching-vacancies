resource "statuscake_uptime_check" "alert" {
  for_each = var.statuscake_alerts

  name           = each.value.website_name
  contact_groups = each.value.contact_group
  confirmation   = 1
  trigger_rate   = 0
  check_interval = 30
  regions        = ["london", "dublin"]

  http_check {
    follow_redirects = true
    timeout          = 40
    request_method   = "HTTP"
    status_codes = [
      "204",
      "205",
      "206",
      "303",
      "400",
      "401",
      "403",
      "404",
      "405",
      "406",
      "408",
      "410",
      "413",
      "444",
      "429",
      "494",
      "495",
      "496",
      "499",
      "500",
      "501",
      "502",
      "503",
      "504",
      "505",
      "506",
      "507",
      "508",
      "509",
      "510",
      "511",
      "521",
      "522",
      "523",
      "524",
      "520",
      "598",
      "599"
    ]

    dynamic "content_matchers" {
      for_each = contains(keys(each.value), "content_matchers") ? each.value.content_matchers : []
      content {
        content = content_matchers.value["content"]
        matcher = content_matchers.value["matcher"]
      }
    }

    dynamic "basic_authentication" {
      for_each = var.statuscake_enable_basic_auth ? [1] : []
      content {
        username = local.application_secrets.SECURE_USERNAME
        password = local.application_secrets.SECURE_PASSWORD
      }
    }
  }

  monitored_resource {
    address = each.value.website_url
  }
}
