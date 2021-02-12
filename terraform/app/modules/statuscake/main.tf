resource statuscake_test alert {
  for_each      = var.statuscake_alerts
  website_name  = each.value.website_name
  website_url   = each.value.website_url
  test_type     = each.value.test_type
  check_rate    = each.value.check_rate
  contact_group = each.value.contact_group
  trigger_rate  = each.value.trigger_rate
  custom_header = each.value.custom_header
  status_codes  = each.value.status_codes
  find_string   = each.value.find_string
  do_not_find   = each.value.do_not_find
  confirmations = 1
}
