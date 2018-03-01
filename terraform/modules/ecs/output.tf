output "cluster_name" {
  value = "${aws_ecs_cluster.cluster.name}"
}

output "service_name" {
  value = "${aws_ecs_service.web.name}"
}

output "desired_service_count" {
  value = "${aws_ecs_service.web.desired_count}"
}

output "registry_name" {
  value = "${aws_ecr_repository.default.name}"
}

output "aws_iam_instance_profile_name" {
  value = "${aws_iam_instance_profile.ecs-instance-profile.name}"
}
