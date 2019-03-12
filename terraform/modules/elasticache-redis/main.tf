# Pulled from https://github.com/turnerlabs/terraform-aws-elasticache-redis
resource "aws_security_group" "redis" {
  vpc_id = "${var.vpc_id}"

  tags {
    Name          = "${var.tag_name}"
    environment   = "${var.tag_environment}"
    team          = "${var.tag_team}"
    application   = "${var.tag_application}"
    contact-email = "${var.tag_contact-email}"
    tag_customer  = "${var.tag_customer}"
  }
}

resource "aws_elasticache_subnet_group" "default" {
  name        = "subnet-group-${var.tag_team}-${var.tag_application}-${var.tag_environment}"
  description = "Private subnets for the ElastiCache instances: ${var.tag_team} ${var.tag_application} ${var.tag_environment}"
  subnet_ids  = ["${split(",", var.private_subnet_ids)}"]
}

resource "aws_elasticache_cluster" "redis_cache" {
  cluster_id           = "${var.cluster_id}cache"
  engine               = "redis"
  engine_version       = "${var.engine_version}"
  maintenance_window   = "${var.maintenance_window}"
  node_type            = "${var.redis_cache_instance_type}"
  num_cache_nodes      = "1"
  parameter_group_name = "${var.parameter_group_name}"
  port                 = "6379"
  subnet_group_name    = "${aws_elasticache_subnet_group.default.name}"
  security_group_ids   = ["${aws_security_group.redis.id}"]

  tags {
    Name          = "${var.tag_name}cache"
    environment   = "${var.tag_environment}"
    team          = "${var.tag_team}"
    application   = "${var.tag_application}"
    contact-email = "${var.tag_contact-email}"
    tag_customer  = "${var.tag_customer}"
  }
}

resource "aws_elasticache_cluster" "redis_queue" {
  cluster_id           = "${var.cluster_id}queue"
  engine               = "redis"
  engine_version       = "${var.engine_version}"
  maintenance_window   = "${var.maintenance_window}"
  node_type            = "${var.redis_queue_instance_type}"
  num_cache_nodes      = "1"
  parameter_group_name = "${var.parameter_group_name}"
  port                 = "6379"
  subnet_group_name    = "${aws_elasticache_subnet_group.default.name}"
  security_group_ids   = ["${aws_security_group.redis.id}"]

  tags {
    Name          = "${var.tag_name}queue"
    environment   = "${var.tag_environment}"
    team          = "${var.tag_team}"
    application   = "${var.tag_application}"
    contact-email = "${var.tag_contact-email}"
    tag_customer  = "${var.tag_customer}"
  }
}
