# Elasticsearch domain
data "aws_subnet_ids" "private" {
  vpc_id = "${var.vpc_id}"
  tags {
    Tier = "Private"
  }
}

resource "aws_elasticsearch_domain" "default" {
  domain_name           = "${var.project_name}-${var.environment}-default"
  elasticsearch_version = "${var.es_version}"

  cluster_config {
    instance_type            = "${var.instance_type}"
    instance_count           = "${var.instance_count}"
    dedicated_master_enabled = true
    dedicated_master_count   = "${var.instance_count}"
    dedicated_master_type    = "${var.instance_type}"
    zone_awareness_enabled   = true
  }

  # advanced_options {
  # }

  ebs_options {
    ebs_enabled = true
    volume_size = "${terraform.workspace == "production" ? 35 : 10}"
    volume_type = "gp2"
  }

  snapshot_options {
    automated_snapshot_start_hour = "02"
  }

  tags {
    Domain = "${var.project_name}-${var.environment}-es"
  }
}

# resource "aws_elasticsearch_domain_policy" "es_management_access" {
#   domain_name     = "${var.project_name}-${var.environment}-es"
#   access_policies = "${data.aws_iam_policy_document.es_management_access.json}"
# }

# data "aws_iam_policy_document" "es_management_access" {
#   count = "${length(var.vpc_options["subnet_ids"]) > 0 ? 0 : 1}"
#   statement {
#     actions = [
#       "es:*",
#     ]
#
#     resources = [
#       "${aws_elasticsearch_domain.es.arn}",
#       "${aws_elasticsearch_domain.es.arn}/*",
#     ]
#
#     principals {
#       type = "AWS"
#
#       identifiers = ["${distinct(compact(var.management_iam_roles))}"]
#     }
#
#     condition {
#       test     = "IpAddress"
#       variable = "aws:SourceIp"
#
#       values = ["${distinct(compact(var.management_public_ip_addresses))}"]
#     }
#   }
# }
