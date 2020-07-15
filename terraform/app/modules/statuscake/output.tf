output "statuscake_test_id" {
  value = "${statuscake_test.alert.*.test_id}"
}
