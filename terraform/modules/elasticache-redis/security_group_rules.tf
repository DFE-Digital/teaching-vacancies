resource "aws_security_group_rule" "redis_in" {
  security_group_id        = "${aws_security_group.redis.id}"
  type                     = "ingress"
  from_port                = 6379
  to_port                  = 6379
  protocol                 = "tcp"
  source_security_group_id = "${var.default_security_group_id}"
}
