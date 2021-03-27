resource "statuscake_test" "alert" {
  for_each       = var.statuscake_alerts
  website_name   = each.value.website_name
  website_url    = each.value.website_url
  test_type      = "HTTP"
  check_rate     = 30
  contact_group  = each.value.contact_group
  trigger_rate   = 0
  find_string    = lookup(each.value, "find_string", null)
  do_not_find    = lookup(each.value, "do_not_find", false)
  confirmations  = 1
  node_locations = ["EC1", "MAN1", "DUB2"]
}
