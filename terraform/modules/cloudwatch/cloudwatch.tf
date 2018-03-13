resource "aws_sns_topic" "cloudwatch_alerts" {
  name = "cloudwatch-alerts"
}

resource "aws_kms_key" "cloudwatch_lambda" {
  description             = "${var.project_name} ${var.environment} cloudwatch lambda kms key"
  deletion_window_in_days = 10
}

resource "aws_kms_alias" "lambda" {
  name          = "alias/${var.project_name}-${var.environment}-cloudwatch-lambda"
  target_key_id = "${aws_kms_key.cloudwatch_lambda.key_id}"
}

resource "aws_cloudwatch_log_group" "cloudwatch_lambda_log_group" {
  name = "${var.project_name}-${var.environment}-cloudwatch_to_slack_opsgenie"
}

resource "aws_iam_role" "slack_lambda_role" {
  name = "${var.project_name}-${var.environment}-slack-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "slack_lambda_policy" {
  name = "${var.project_name}-${var.environment}-slack-lambda-policy"
  role = "${aws_iam_role.slack_lambda_role.id}"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Action": [
        "kms:Decrypt"
      ],
      "Resource": [
        "${aws_kms_key.cloudwatch_lambda.arn}"
      ]
    },
    {
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
        ],
        "Resource": [
            "${aws_cloudwatch_log_group.cloudwatch_lambda_log_group.arn}"
        ]
    }
  ]
}
EOF
}

resource "aws_lambda_function" "cloudwatch_to_slack" {
  filename         = "lambda_cloudwatch_to_slack_opsgenie_payload.zip"
  function_name    = "${var.project_name}-${var.environment}-cloudwatch_to_slack_opsgenie"
  role             = "${aws_iam_role.slack_lambda_role.arn}"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = "${base64sha256(file("lambda_cloudwatch_to_slack_opsgenie_payload.zip"))}"
  runtime          = "python3.6"
  timeout          = "10"
  kms_key_arn      = "${aws_kms_key.cloudwatch_lambda.arn}"

  environment {
    variables = {
      slackHookUrl   = "${var.slack_hook_url}"
      slackChannel   = "${var.slack_channel}"
      opsGenieApiKey = "${var.ops_genie_api_key}"
    }
  }
}

resource "aws_sns_topic_subscription" "cloudwatch_to_slack_lambda_subscription" {
  topic_arn = "${aws_sns_topic.cloudwatch_alerts.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.cloudwatch_to_slack.arn}"
}

resource "aws_lambda_permission" "with_sns" {
    statement_id = "AllowExecutionFromSNS"
    action = "lambda:InvokeFunction"
    function_name = "${aws_lambda_function.cloudwatch_to_slack.arn}"
    principal = "sns.amazonaws.com"
    source_arn = "${aws_sns_topic.cloudwatch_alerts.arn}"
}

resource "aws_cloudwatch_metric_alarm" "cpu" {

  alarm_name                = "${var.project_name}-${var.environment}-cpu"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "120"
  statistic                 = "Average"
  threshold                 = "80"

  alarm_description         = "This metric monitors ec2 cpu utilization within the autoscaling group ${var.autoscaling_group_name}"
  alarm_actions             = ["${aws_sns_topic.cloudwatch_alerts.arn}"]
  ok_actions                = ["${aws_sns_topic.cloudwatch_alerts.arn}"]

  dimensions {
    AutoScalingGroupName    = "${var.autoscaling_group_name}"
  }

}
