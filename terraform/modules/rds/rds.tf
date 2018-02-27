resource "aws_db_instance" "default" {
  name                      = "${var.project_name}${var.environment}"
  identifier                = "${var.project_name}${var.environment}"
  allocated_storage         = "${var.rds_storage_gb}"
  storage_type              = "gp2"
  storage_encrypted         = "true"
  engine                    = "${var.rds_engine}"
  engine_version            = "${var.rds_engine_version}"
  instance_class            = "${var.rds_instance}"
  name                      = "${var.project_name}${var.environment}" # alphanumeric only
  username                  = "${var.rds_username}"
  password                  = "${var.rds_password}"
  vpc_security_group_ids    = ["${var.default_security_group_id}"]
  db_subnet_group_name      = "${aws_db_subnet_group.default.name}"
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.project_name}-${var.environment}-final-snapshot"
  backup_retention_period   = 14
  maintenance_window        = "Sun:00:00-Sun:03:00"
  multi_az                  = "${terraform.workspace == "production" ? "true" : "false"}"

  tags {
    Name        = "${var.project_name}-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_db_subnet_group" "default" {
  name        = "${var.project_name}-${var.environment}"
  subnet_ids  = ["${data.aws_subnet_ids.private.ids}"]
}

data "aws_subnet_ids" "private" {
  vpc_id = "${var.vpc_id}"
  tags {
    Tier = "Private"
  }
}
