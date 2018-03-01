output "es_address" {
  value = "${aws_elasticsearch_domain.default.endpoint}"
}
