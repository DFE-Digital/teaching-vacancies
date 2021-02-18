variable "region" { default = "eu-west-2" }

variable "s3_bucket_name" { default = "terraform-state-002" }

locals {
  # awslogsdelivery ID from https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html#AccessLogsBucketAndFileOwnership
  aws_canonical_user_id_awslogsdelivery = "c4c1ede66af53448b93c283ce9448c4ba468c9432aa01d700d3878632f77d2d0"
  primary_zone_name                     = "teaching-vacancies.service.gov.uk"
  secondary_zone_name                   = "teaching-jobs.service.gov.uk"
  service_name                          = "teaching-vacancies"
  service_abbreviation                  = "TV"
}
