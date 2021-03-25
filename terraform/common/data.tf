data "aws_caller_identity" "current" {}

data "aws_s3_bucket" "terraform_state" {
  bucket = "${data.aws_caller_identity.current.account_id}-terraform-state"
}
