/*====
The VPC
======*/
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = "${var.environment}"
  }
}

/*====
Subnets
======*/
/* Internet gateway for the public subnet */
resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.project_name}-${var.environment}-igw"
    Environment = "${var.environment}"
  }
}

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = ["aws_internet_gateway.ig"]
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = "${aws_eip.nat_eip.id}"
  subnet_id     = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  depends_on    = ["aws_internet_gateway.ig"]

  tags {
    Name        = "${var.project_name}-${var.environment}-${element(var.availability_zones, count.index)}-nat"
    Environment = "${var.environment}"
  }
}

/* Public subnet */
resource "aws_subnet" "public_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.public_subnets_cidr)}"
  cidr_block              = "${element(var.public_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = true

  tags {
    Name        = "${var.project_name}-${var.environment}-${element(var.availability_zones, count.index)}-public-subnet"
    Environment = "${var.environment}"
    Tier        = "Public"
  }
}

/* Private subnet */
resource "aws_subnet" "private_subnet" {
  vpc_id                  = "${aws_vpc.vpc.id}"
  count                   = "${length(var.private_subnets_cidr)}"
  cidr_block              = "${element(var.private_subnets_cidr, count.index)}"
  availability_zone       = "${element(var.availability_zones, count.index)}"
  map_public_ip_on_launch = false

  tags {
    Name        = "${var.environment}-${element(var.availability_zones, count.index)}-private-subnet"
    Environment = "${var.environment}"
    Tier        = "Private"
  }
}

/* Routing table for private subnet */
resource "aws_route_table" "private" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.environment}-private-route-table"
    Environment = "${var.environment}"
  }
}

/* Routing table for public subnet */
resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags {
    Name        = "${var.environment}-public-route-table"
    Environment = "${var.environment}"
  }
}

resource "aws_route" "public_internet_gateway" {
  route_table_id         = "${aws_route_table.public.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.ig.id}"
}

resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.private.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.nat.id}"
}

/* Route table associations */
resource "aws_route_table_association" "public" {
  count          = "${length(var.public_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.public_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "private" {
  count          = "${length(var.private_subnets_cidr)}"
  subnet_id      = "${element(aws_subnet.private_subnet.*.id, count.index)}"
  route_table_id = "${aws_route_table.private.id}"
}

/*====
VPC's Default Security Group
======*/
resource "aws_security_group" "default" {
  name        = "${var.environment}-default-sg"
  description = "Default security group to allow inbound/outbound from the VPC"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
    self      = true
  }

  tags {
    Name        = "${var.project_name}-${var.environment}"
    Environment = "${var.environment}"
  }

  depends_on = ["aws_vpc.vpc"]
}

/* ECS agents need to communicate with AWS to register to the cluster */
resource "aws_security_group" "ecs" {
  name        = "${var.project_name}-${var.environment}-ecs"
  description = "ECS instance security group so we can it can communicate with AWS"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = "${var.ssh_ips}"
  }

  ingress {
    from_port       = 32768
    to_port         = 65535
    protocol        = "tcp"
    security_groups = ["${aws_security_group.web_inbound_sg.id}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name        = "${var.project_name}-${var.environment}"
    Environment = "${var.environment}"
  }

  depends_on = ["aws_vpc.vpc"]
}

/*====
Load balancer definitions
======*/
resource "aws_alb" "alb_default" {
  name            = "${var.project_name}-alb-${var.environment}"
  subnets         = ["${aws_subnet.public_subnet.*.id}"]
  security_groups = ["${aws_security_group.web_inbound_sg.id}"]

  tags {
    Name        = "${var.project_name}-alb-${var.environment}"
    Environment = "${var.environment}"
  }
}

resource "aws_alb_listener" "default" {
  load_balancer_arn = "${aws_alb.alb_default.arn}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"
  }

  depends_on = ["aws_alb_target_group.alb_target_group"]
}

resource "aws_lb_listener_rule" "redirect_all_http_requests_to_https" {
  listener_arn = "${aws_alb_listener.default.arn}"

  action {
    type = "redirect"

    redirect {
      host        = "${var.domain}"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    field  = "path-pattern"
    values = ["/*"]
  }
}

resource "aws_alb_listener" "default_https" {
  load_balancer_arn = "${aws_alb.alb_default.arn}"
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = "${var.alb_certificate_arn}"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"
  }

  depends_on = ["aws_alb_target_group.alb_target_group"]
}

resource "aws_lb_listener_rule" "redirect_old_teachingjobs_https_traffic" {
  count        = "${var.redirect_old_teachingjobs_traffic}"
  listener_arn = "${aws_alb_listener.default_https.arn}"

  action {
    type = "redirect"

    redirect {
      host        = "${var.domain}"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    field  = "host-header"
    values = ["teaching-jobs.service.gov.uk"]
  }
}

resource "aws_lb_listener_rule" "redirect_old_teachingjobs_https_traffic_with_www_subdomain" {
  listener_arn = "${aws_alb_listener.default_https.arn}"

  action {
    type = "redirect"

    redirect {
      host        = "${var.domain}"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    field  = "host-header"
    values = ["www.teaching-jobs.service.gov.uk"]
  }
}

resource "aws_lb_listener_rule" "redirect_https_traffic_with_www_subdomain" {
  listener_arn = "${aws_alb_listener.default_https.arn}"

  action {
    type = "redirect"

    redirect {
      host        = "${var.domain}"
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }

  condition {
    field  = "host-header"
    values = ["www.${var.domain}"]
  }
}

resource "aws_alb_target_group" "alb_target_group" {
  name     = "${var.project_name}-${var.environment}-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.vpc.id}"

  health_check {
    healthy_threshold   = "5"
    unhealthy_threshold = "3"
    interval            = "30"
    matcher             = "200"
    path                = "${var.load_balancer_check_path}"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = "5"
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_alb.alb_default"]
}

/* security group for ALB */
resource "aws_security_group" "web_inbound_sg" {
  name        = "${var.project_name}-${var.environment}-inbound"
  description = "Allow HTTP from dxw into ALB"
  vpc_id      = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # CloudFront changes IP so requires this to allow any IP
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # CloudFront changes IP so requires this to allow any IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "${var.project_name}-${var.environment}-inbound"
  }
}

/*====
Autoscaling
======*/

resource "aws_iam_role" "ecs_autoscale_role" {
  name               = "${var.project_name}_${var.environment}_ecs_autoscale_role"
  assume_role_policy = "${file("./terraform/policies/ecs-autoscale-role.json")}"
}

resource "aws_iam_role_policy" "ecs_autoscale_role_policy" {
  name   = "${var.project_name}_${var.environment}_ecs_autoscale_role_policy"
  policy = "${file("./terraform/policies/ecs-autoscale-role-policy.json")}"
  role   = "${aws_iam_role.ecs_autoscale_role.id}"
}

resource "aws_autoscaling_policy" "ecs-autoscaling-up-policy" {
  name                    = "${var.project_name}-${var.environment}-${var.asg_name}-scale-up"
  scaling_adjustment      = 2
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  autoscaling_group_name  = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
  policy_type             = "SimpleScaling"
}

resource "aws_autoscaling_policy" "ecs-autoscaling-down-policy" {
  name                    = "${var.project_name}-${var.environment}-${var.asg_name}-scale-down"
  scaling_adjustment      = -1
  adjustment_type         = "ChangeInCapacity"
  cooldown                = 300
  autoscaling_group_name  = "${aws_autoscaling_group.ecs-autoscaling-group.name}"
  policy_type             = "SimpleScaling"
}

resource "aws_cloudwatch_metric_alarm" "cluster-cpu-reservation-high" {
  alarm_name          = "${var.project_name}-${var.environment}-cluster-cpu-reservation-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "40"

  dimensions {
    ClusterName = "${var.ecs_cluster_name}"
  }

  alarm_description = "This metric monitors ${aws_autoscaling_group.ecs-autoscaling-group.name} for high cpu reservation"
  alarm_actions     = ["${aws_autoscaling_policy.ecs-autoscaling-up-policy.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "cluster-cpu-reservation-low" {
  alarm_name          = "${var.project_name}-${var.environment}-cluster-cpu-reservation-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "5"
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "35"

  dimensions {
    ClusterName = "${var.ecs_cluster_name}"
  }

  alarm_description = "This metric monitors ${aws_autoscaling_group.ecs-autoscaling-group.name} for low cpu reservation"
  alarm_actions     = ["${aws_autoscaling_policy.ecs-autoscaling-down-policy.arn}"]
}

resource "aws_autoscaling_group" "ecs-autoscaling-group" {
  # Naming important to tie it to launch configuration: https://github.com/hashicorp/terraform/issues/532#issuecomment-272263827
  name                 = "${var.project_name}-${var.environment}-${var.asg_name}-${aws_launch_configuration.ecs-launch-configuration.name}"
  availability_zones   = "${var.availability_zones}"
  max_size             = "${var.asg_max_size}"
  min_size             = "${var.asg_min_size}"
  desired_capacity     = "${var.asg_desired_size}"
  vpc_zone_identifier  = ["${aws_subnet.public_subnet.*.id}"]
  launch_configuration = "${aws_launch_configuration.ecs-launch-configuration.name}"
  health_check_type    = "ELB"

  tags = [
    {
      key                 = "Name"
      value               = "${var.project_name}-${var.environment}"
      propagate_at_launch = true
    },
  ]

  depends_on = ["aws_vpc.vpc", "aws_launch_configuration.ecs-launch-configuration", "aws_security_group.default", "aws_security_group.ecs"]

  # Requires commenting out if the `asg_desired_size` variable in .tfvars is changed
  # in either direction.
  lifecycle {
    ignore_changes = ["desired_capacity"]
  }
}

resource "aws_appautoscaling_target" "target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_web_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  role_arn           = "${aws_iam_role.ecs_autoscale_role.arn}"
  min_capacity       = 6
  max_capacity       = 20
}

resource "aws_appautoscaling_policy" "up" {
  name               = "${var.project_name}_${var.environment}_scale_up"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_web_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 30
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_lower_bound = 0
      scaling_adjustment          = 4
    }
  }

  depends_on = ["aws_appautoscaling_target.target"]
}

resource "aws_appautoscaling_policy" "down" {
  name               = "${var.project_name}_${var.environment}_scale_down"
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${var.ecs_service_web_name}"
  scalable_dimension = "ecs:service:DesiredCount"

  step_scaling_policy_configuration {
    adjustment_type         = "ChangeInCapacity"
    cooldown                = 60
    metric_aggregation_type = "Maximum"

    step_adjustment {
      metric_interval_upper_bound = 0
      scaling_adjustment          = -2
    }
  }

  depends_on = ["aws_appautoscaling_target.target"]
}

/* metric used for auto scale */
resource "aws_cloudwatch_metric_alarm" "web-cpu-utilisation-high" {
  alarm_name          = "${var.project_name}-${var.environment}-web-cpu-utilisation-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "30"

  dimensions {
    ClusterName = "${var.ecs_cluster_name}"
    ServiceName = "${var.ecs_service_web_name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.up.arn}"]
  ok_actions    = ["${aws_appautoscaling_policy.down.arn}"]
}

resource "aws_cloudwatch_metric_alarm" "web-memory-utilisation-high" {
  alarm_name          = "${var.project_name}-${var.environment}-web-memory-utilisation-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "60"
  statistic           = "Average"
  threshold           = "80"

  dimensions {
    ClusterName = "${var.ecs_cluster_name}"
    ServiceName = "${var.ecs_service_web_name}"
  }

  alarm_actions = ["${aws_appautoscaling_policy.up.arn}"]
  ok_actions    = ["${aws_appautoscaling_policy.down.arn}"]
}

/*====
Launch configuration
======*/

resource "aws_launch_configuration" "ecs-launch-configuration" {
  image_id                    = "${var.image_id}"
  instance_type               = "${var.instance_type}"
  iam_instance_profile        = "${var.aws_iam_ecs_instance_profile_name}"
  security_groups             = ["${aws_security_group.default.id}", "${aws_security_group.ecs.id}"]
  associate_public_ip_address = "true"
  key_name                    = "${var.ecs_key_pair_name}"
  user_data                   = "${data.template_file.ecs-launch-configuration-user-data.rendered}"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = ["aws_vpc.vpc", "aws_security_group.default", "aws_security_group.ecs"]
}

data "template_file" "ecs-launch-configuration-user-data" {
  template = "${file("./terraform/cloud-config/container-instance.yml.tpl")}"

  vars {
    ecs_cluster_name = "${var.ecs_cluster_name}"
  }
}
