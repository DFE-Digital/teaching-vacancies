variable environment {
}

variable postgres_service_plan {
}

variable project_name {
}

variable space_name {
}

locals {
  postgres_service_name = "${var.project_name}-postgres-${var.environment}"
}
