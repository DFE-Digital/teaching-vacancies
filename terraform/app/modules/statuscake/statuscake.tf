resource "statuscake_test" "alert" {
  count         = "${length(var.statuscake_alerts)}"

  website_name  = "${element(var.statuscake_alerts["${element(keys(var.statuscake_alerts), count.index)}"], 0)}"
  website_url   = "${element(var.statuscake_alerts["${element(keys(var.statuscake_alerts), count.index)}"], 1)}"
  test_type     = "${element(var.statuscake_alerts["${element(keys(var.statuscake_alerts), count.index)}"], 2)}"
  check_rate    = "${element(var.statuscake_alerts["${element(keys(var.statuscake_alerts), count.index)}"], 3)}"
  contact_id    = "${element(var.statuscake_alerts["${element(keys(var.statuscake_alerts), count.index)}"], 4)}"
  trigger_rate  = "${element(var.statuscake_alerts["${element(keys(var.statuscake_alerts), count.index)}"], 5)}"
  custom_header = "${element(var.statuscake_alerts["${element(keys(var.statuscake_alerts), count.index)}"], 6)}"
  status_codes  = "${element(var.statuscake_alerts["${element(keys(var.statuscake_alerts), count.index)}"], 7)}"
  
}