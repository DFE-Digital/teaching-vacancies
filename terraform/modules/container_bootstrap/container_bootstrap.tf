resource "aws_s3_bucket" "container_bootstrap_bucket" {
  bucket = "${var.project_name}-${var.environment}-container-bootstrap-scripts"
  acl    = "private"

  tags {
    Name        = "${var.project_name} ${var.environment} Container Bootstrap"
  }
}

resource "aws_kms_key" "parameter_store" {
  description             = "${var.project_name} ${var.environment} parameter store kms key"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "parameter_store" {
  name          = "alias/${var.project_name}-${var.environment}-parameter-store"
  target_key_id = "${aws_kms_key.parameter_store.key_id}"
}

data "template_file" "container_bootstrap_s3_read_policy" {
  template = "${file("./terraform/policies/s3-read-policy.json")}"

  vars {
    s3_bucket_arn = "${aws_s3_bucket.container_bootstrap_bucket.arn}"
  }
}

data "template_file" "container_bootstrap_parameter_store_policy" {
  template = "${file("./terraform/policies/get-parameters-by-path-policy.json")}"

  vars {
    parameter_store_path = "${var.parameter_store_path}"
    kms_key_arn          = "${aws_kms_key.parameter_store.arn}"
  }
}

resource "aws_iam_role_policy" "container_bootstrap_s3_read_policy" {
  name        = "${var.project_name}-${var.environment}-container-bootstrap-s3-read-policy"
  role        = "${var.ecs_task_role_id}"
  policy      = "${data.template_file.container_bootstrap_s3_read_policy.rendered}"
}

resource "aws_iam_role_policy" "parameter_store_kms_key_policy" {
  name        = "${var.project_name}-${var.environment}-parameter-store-kms-key-policy"
  role        = "${var.ecs_task_role_id}"
  policy      = "${data.template_file.container_bootstrap_parameter_store_policy.rendered}"
}

resource "aws_s3_bucket_object" "container_bootstrap_script" {
  bucket = "${aws_s3_bucket.container_bootstrap_bucket.id}"
  key    = "container_bootstrap.sh"
  source = "./terraform/scripts/container_bootstrap.sh"
  etag   = "${md5(file("./terraform/scripts/container_bootstrap.sh"))}"
}

resource "aws_s3_bucket_object" "setup_secrets_script" {
  bucket = "${aws_s3_bucket.container_bootstrap_bucket.id}"
  key    = "setup_secrets.sh"
  source = "./terraform/scripts/setup_secrets.sh"
  etag   = "${md5(file("./terraform/scripts/setup_secrets.sh"))}"
}

resource "aws_s3_bucket_object" "aws_parameter_to_env_script" {
  bucket = "${aws_s3_bucket.container_bootstrap_bucket.id}"
  key    = "aws_parameter_to_env.py"
  source = "./terraform/scripts/aws_parameter_to_env.py"
  etag   = "${md5(file("./terraform/scripts/aws_parameter_to_env.py"))}"
}
