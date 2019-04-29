output "template" {
  value = "${data.template_file.container_definition_template.rendered}"
}
