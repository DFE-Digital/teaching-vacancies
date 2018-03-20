resource "aws_ssm_parameter" "string_parameters" {
  count     = "${length(var.string_parameters)}"

  name      = "${var.namespace}/${element( split("=", element(var.string_parameters, count.index) ), 0)}"
  value     = "${ join( "=", slice( split("=", element(var.string_parameters, count.index) ), 1, length(split("=", element(var.string_parameters, count.index) ) ) ) ) }"
  type      = "String"

  overwrite = true
}

resource "aws_ssm_parameter" "secure_string_parameters" {
  count     = "${length(var.secure_string_parameters)}"

  name      = "${var.namespace}/${element( split("=", element(var.secure_string_parameters, count.index) ), 0)}"
  value     = "${ join( "=", slice( split("=", element(var.secure_string_parameters, count.index) ), 1, length(split("=", element(var.secure_string_parameters, count.index) ) ) ) ) }"
  type      = "SecureString"

  key_id    = "${var.kms_key_alias}"

  overwrite = true
}
