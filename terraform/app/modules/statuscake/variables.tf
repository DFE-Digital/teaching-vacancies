variable environment {
}

variable service_name {
}

variable statuscake_alerts {
  description = "Define Statuscake alerts with the attributes below"
  type = map(object({
    website_name  = string
    website_url   = string
    test_type     = string
    check_rate    = string
    contact_group = list(string)
    trigger_rate  = string
    find_string   = string
    do_not_find   = bool
  }))
}
