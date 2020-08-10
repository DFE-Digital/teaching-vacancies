variable environment {
}

variable papertrail_url {
}

variable postgres_service_plan {
}

variable project_name {
}

variable redis_service_plan {
}

variable space_name {
}

locals {
  papertrail_service_name = "${var.project_name}-papertrail-${var.environment}"
  postgres_service_name   = "${var.project_name}-postgres-${var.environment}"
  redis_service_name      = "${var.project_name}-redis-${var.environment}"
}
