resource "aws_s3_bucket" "documents_s3_bucket" {
  bucket        = local.documents_s3_bucket_name
  force_destroy = var.documents_s3_bucket_force_destroy
}

resource "aws_s3_bucket_cors_configuration" "documents_s3_bucket" {
  bucket = aws_s3_bucket.documents_s3_bucket.id

  cors_rule {
    allowed_headers = ["Content-Type", "Content-MD5", "Content-Disposition"]
    allowed_methods = ["PUT"]
    allowed_origins = ["https://${local.web_app_domain}"]
    expose_headers  = []
    max_age_seconds = 3600
  }
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

# Azure Storage Account for Documents
module "documents_azure_storage" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/storage_account?ref=stable"

  name                  = "doc"
  environment           = var.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  # Redundancy: ZRS for production, LRS for non-prod (module enforced)
  production_replication_type = var.azure_storage_production_replication_type

  # Security settings
  public_network_access_enabled     = true # Required for app access
  infrastructure_encryption_enabled = false

  # Versioning and retention
  blob_versioning_enabled         = var.azure_storage_blob_versioning_enabled
  blob_delete_retention_days      = var.azure_storage_blob_delete_retention_days
  container_delete_retention_days = var.azure_storage_blob_delete_retention_days
  blob_delete_after_days          = var.azure_storage_blob_delete_after_days

  # Container for documents
  containers = [
    { name = "documents" }
  ]

  create_encryption_scope = false
}

# Azure Storage Account for School Images/Logos
module "images_logos_azure_storage" {
  source = "git::https://github.com/DFE-Digital/terraform-modules.git//aks/storage_account?ref=stable"

  name                  = "img"
  environment           = var.environment
  azure_resource_prefix = var.azure_resource_prefix
  service_short         = var.service_short
  config_short          = var.config_short

  # Redundancy: ZRS for production, LRS for non-prod (module enforced)
  production_replication_type = var.azure_storage_production_replication_type

  # Security settings
  public_network_access_enabled     = true # Required for app access
  infrastructure_encryption_enabled = false

  # Versioning and retention
  blob_versioning_enabled         = var.azure_storage_blob_versioning_enabled
  blob_delete_retention_days      = var.azure_storage_blob_delete_retention_days
  container_delete_retention_days = var.azure_storage_blob_delete_retention_days
  blob_delete_after_days          = var.azure_storage_blob_delete_after_days

  # Container for images/logos
  containers = [
    { name = "images-logos" }
  ]

  create_encryption_scope = false
}
