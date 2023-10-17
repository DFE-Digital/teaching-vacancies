resource "cloudfoundry_service_instance" "postgres_instance" {
  name         = local.postgres_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_service_plan]
  json_params  = jsonencode(local.postgres_json_params)
  timeouts {
    create = "30m"
    delete = "30m"
    update = "60m"
  }
}

resource "cloudfoundry_service_key" "postgres_instance_service_key" {
  name             = "postgres_instance_service_key-${var.environment}"
  service_instance = cloudfoundry_service_instance.postgres_instance.id
}

resource "cloudfoundry_service_instance" "redis_cache_instance" {
  name         = local.redis_cache_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.redis_cache_service_plan]
  json_params  = "{\"maxmemory_policy\": \"allkeys-lru\"}"
}

resource "cloudfoundry_service_instance" "redis_queue_instance" {
  name         = local.redis_queue_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.redis.service_plans[var.redis_queue_service_plan]
  json_params  = "{\"maxmemory_policy\": \"noeviction\"}"
}

resource "aws_s3_bucket" "documents_s3_bucket" {
  bucket        = local.documents_s3_bucket_name
  force_destroy = var.documents_s3_bucket_force_destroy
}

resource "aws_s3_bucket" "schools_images_logos_s3_bucket" {
  bucket        = local.schools_images_logos_s3_bucket_name
  force_destroy = var.schools_images_logos_s3_bucket_force_destroy
}

resource "aws_s3_bucket_public_access_block" "documents_s3_bucket_block" {
  bucket = aws_s3_bucket.documents_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "schools_images_logos_s3_bucket_block" {
  bucket = aws_s3_bucket.schools_images_logos_s3_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_policy" "documents_s3_bucket_policy" {
  name   = "${local.documents_s3_bucket_name}-policy"
  path   = "/attachment_buckets_policies/"
  policy = data.aws_iam_policy_document.documents_s3_bucket_policy_document.json
}

resource "aws_iam_policy" "schools_images_logos_s3_bucket_policy" {
  name   = "${local.schools_images_logos_s3_bucket_name}-policy"
  path   = "/attachment_images_logos_buckets_policies/"
  policy = data.aws_iam_policy_document.schools_images_logos_s3_bucket_policy_document.json
}

data "aws_iam_policy_document" "documents_s3_bucket_policy_document" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.documents_s3_bucket.arn}/*"]
    effect    = "Allow"
  }
}

data "aws_iam_policy_document" "schools_images_logos_s3_bucket_policy_document" {
  statement {
    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject"
    ]
    resources = ["${aws_s3_bucket.schools_images_logos_s3_bucket.arn}/*"]
    effect    = "Allow"
  }
}

resource "aws_iam_user" "documents_s3_bucket_user" {
  name = "${local.documents_s3_bucket_name}-user"
  path = "/attachment_buckets_users/"
}

resource "aws_iam_user" "schools_images_logos_s3_bucket_user" {
  name = "${local.schools_images_logos_s3_bucket_name}-user"
  path = "/attachment_images_logos_buckets_users/"
}

resource "aws_iam_access_key" "documents_s3_bucket_access_key" {
  user = aws_iam_user.documents_s3_bucket_user.name
}

resource "aws_iam_access_key" "schools_images_logos_s3_bucket_access_key" {
  user = aws_iam_user.schools_images_logos_s3_bucket_user.name
}

resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.documents_s3_bucket_user.name
  policy_arn = aws_iam_policy.documents_s3_bucket_policy.arn
}

resource "aws_iam_user_policy_attachment" "attachment_images_logos" {
  user       = aws_iam_user.schools_images_logos_s3_bucket_user.name
  policy_arn = aws_iam_policy.schools_images_logos_s3_bucket_policy.arn
}
