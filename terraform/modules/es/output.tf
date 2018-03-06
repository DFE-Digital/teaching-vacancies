output "es_address" {
  value = "${aws_elasticsearch_domain.default.endpoint}"
}

output "es_user_access_key_id" {
  value = "${element(concat( aws_iam_access_key.es_user_access_key.*.id, list("")), 0)}"
}

output "es_user_access_key_secret" {
  value = "${element(concat( aws_iam_access_key.es_user_access_key.*.secret, list("")), 0)}"
}
