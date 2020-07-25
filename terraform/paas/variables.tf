variable cf_user {}

variable cf_password {}

variable cf_space_name {}

variable postgres_service_name {}

variable redis_service_name {}

variable papertrail_service_name {}

variable web_app_name {}

variable worker_app_name {}

variable app_stopped { default = false }

variable app_docker_image {}

variable no_of_instances { default = 1 }

variable app_memory { default = 512 }

variable app_start_timeout { default = 300 }

variable service_recursive_delete { default = false }
