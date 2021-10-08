resource "cloudfoundry_service_instance" "postgres_instance" {
  name         = local.postgres_service_name
  space        = data.cloudfoundry_space.space.id
  service_plan = data.cloudfoundry_service.postgres.service_plans[var.postgres_service_plan]
  json_params  = "{\"enable_extensions\": [\"pgcrypto\", \"fuzzystrmatch\", \"plpgsql\", \"pg_trgm\", \"postgis\"]}"
  timeouts {
    create = "30m"
    delete = "30m"
    update = "60m"
  }
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

resource "cloudfoundry_user_provided_service" "papertrail" {
  name             = local.papertrail_service_name
  space            = data.cloudfoundry_space.space.id
  syslog_drain_url = var.papertrail_url
}

resource "cloudfoundry_user_provided_service" "logit" {
  name             = local.logit_service_name
  space            = data.cloudfoundry_space.space.id
  syslog_drain_url = var.logit_url
}

resource "aws_s3_bucket" "documents_s3_bucket" {
  bucket        = local.documents_s3_bucket_name
  force_destroy = var.documents_s3_bucket_force_destroy
}

resource "aws_s3_bucket_public_access_block" "documents_s3_bucket_block" {
  bucket = aws_s3_bucket.documents_s3_bucket.id

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

resource "aws_iam_user" "documents_s3_bucket_user" {
  name = "${local.documents_s3_bucket_name}-user"
  path = "/attachment_buckets_users/"
}

resource "aws_iam_access_key" "documents_s3_bucket_access_key" {
  user = aws_iam_user.documents_s3_bucket_user.name
}

resource "aws_iam_user_policy_attachment" "attachment" {
  user       = aws_iam_user.documents_s3_bucket_user.name
  policy_arn = aws_iam_policy.documents_s3_bucket_policy.arn
}

resource "cloudfoundry_app" "web_app" {
  name                       = local.web_app_name
  command                    = var.web_app_start_command
  docker_image               = var.app_docker_image
  health_check_type          = "http"
  health_check_http_endpoint = "/check"
  health_check_timeout       = 60
  instances                  = var.web_app_instances
  memory                     = var.web_app_memory
  routes {
    route = cloudfoundry_route.web_app_route.id
  }
  dynamic "routes" {
    for_each = cloudfoundry_route.web_app_route_cloudfront_apex
    content {
      route = routes.value["id"]
    }
  }
  dynamic "routes" {
    for_each = cloudfoundry_route.web_app_route_cloudfront_subdomain
    content {
      route = routes.value["id"]
    }
  }
  docker_credentials = {
    username = var.docker_username
    password = var.docker_password
  }
  space    = data.cloudfoundry_space.space.id
  stopped  = var.app_stopped
  strategy = var.web_app_deployment_strategy
  timeout  = var.app_start_timeout
  dynamic "service_binding" {
    for_each = local.app_service_bindings
    content {
      service_instance = service_binding.value
    }
  }
  environment = local.app_environment
}

resource "cloudfoundry_route" "web_app_route" {
  domain   = data.cloudfoundry_domain.cloudapps_digital.id
  space    = data.cloudfoundry_space.space.id
  hostname = local.web_app_name
}

resource "cloudfoundry_route" "web_app_route_cloudfront_apex" {
  for_each = toset(var.route53_a_records)
  domain   = data.cloudfoundry_domain.cloudfront[each.key].id
  space    = data.cloudfoundry_space.space.id
}

resource "cloudfoundry_route" "web_app_route_cloudfront_subdomain" {
  for_each = var.hostname_domain_map
  domain   = data.cloudfoundry_domain.cloudfront[each.value["domain"]].id
  space    = data.cloudfoundry_space.space.id
  hostname = each.value["hostname"]
}

resource "cloudfoundry_app" "worker_app" {
  name                 = local.worker_app_name
  command              = local.worker_app_start_command
  docker_image         = var.app_docker_image
  health_check_type    = "process"
  health_check_timeout = 10
  instances            = var.worker_app_instances
  memory               = var.worker_app_memory
  space                = data.cloudfoundry_space.space.id
  stopped              = var.app_stopped
  strategy             = var.worker_app_deployment_strategy
  timeout              = var.app_start_timeout
  dynamic "service_binding" {
    for_each = local.app_service_bindings
    content {
      service_instance = service_binding.value
    }
  }
  docker_credentials = {
    username = var.docker_username
    password = var.docker_password
  }
  environment = local.app_environment
}
