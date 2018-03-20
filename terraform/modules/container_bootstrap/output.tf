output "entrypoint" {
  value = "apt-get update && apt-get -y install python-dev python2.7 curl && curl -O https://bootstrap.pypa.io/get-pip.py && python2.7 get-pip.py && rm get-pip.py && pip install awscli && aws s3 cp s3://${aws_s3_bucket.container_bootstrap_bucket.id}/container_bootstrap.sh . && /bin/bash container_bootstrap.sh -b ${aws_s3_bucket.container_bootstrap_bucket.id} -p ${var.parameter_store_path} -r ${var.region} -u ${var.dotenv_user} &&"
}

output "parameter_store_kms_key_alias" {
  value = "${aws_kms_alias.parameter_store.name}"
}
