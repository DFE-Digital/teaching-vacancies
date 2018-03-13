output "vpc_id" {
  value = "${aws_vpc.vpc.id}"
}

output "alb_dns_name" {
  value = "${aws_alb.alb_default.dns_name}"
}

output "alb_target_group_arn" {
  value = "${aws_alb_target_group.alb_target_group.arn}"
}

output "default_security_group_id" {
  value = "${aws_security_group.default.id}"
}

output "ecs_autoscaling_group_name" {
  value = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
}
