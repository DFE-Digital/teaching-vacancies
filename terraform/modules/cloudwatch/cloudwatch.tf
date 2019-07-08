data "aws_caller_identity" "current" {}

resource "aws_sns_topic" "cloudwatch_alerts" {
  name = "${var.project_name}-${var.environment}-cloudwatch-alerts"
}

resource "aws_sns_topic_policy" "sns_cloudwatch_alerts" {
  arn = "${aws_sns_topic.cloudwatch_alerts.arn}"

  policy = "${data.template_file.sns_cloudwatch_alerts_policy.rendered}"
}

data "template_file" "sns_cloudwatch_alerts_policy" {
  template = "${file("./terraform/policies/sns-policy.json")}"

  vars {
    policy_id      = "${var.project_name}-${var.environment}-cloudwatch-alerts-policy"
    sns_arn        = "${aws_sns_topic.cloudwatch_alerts.arn}"
    aws_account_id = "${data.aws_caller_identity.current.account_id}"
  }
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
  name = "/aws/lambda/${var.project_name}-${var.environment}-cloudwatch_to_slack_opsgenie"
}

resource "aws_iam_role" "slack_lambda_role" {
  name               = "${var.project_name}-${var.environment}-slack-lambda-role"
  assume_role_policy = "${file("./terraform/policies/cloudwatch-slack-lambda-role.json")}"
}

data "template_file" "slack_lambda_policy" {
  template = "${file("./terraform/policies/cloudwatch-slack-lambda-policy.json")}"

  vars {
    cloudwatch_lambda_log_group_arn = "${aws_cloudwatch_log_group.cloudwatch_lambda_log_group.arn}"
    cloudwatch_lambda_kms_key_arn   = "${aws_kms_key.cloudwatch_lambda.arn}"
  }
}

resource "aws_iam_role_policy" "slack_lambda_policy" {
  name   = "${var.project_name}-${var.environment}-slack-lambda-policy"
  role   = "${aws_iam_role.slack_lambda_role.id}"
  policy = "${data.template_file.slack_lambda_policy.rendered}"
}

resource "aws_lambda_function" "cloudwatch_to_slack" {
  filename         = "lambda_cloudwatch_to_slack_opsgenie_payload.zip"
  function_name    = "${var.project_name}-${var.environment}-cloudwatch_to_slack_opsgenie"
  role             = "${aws_iam_role.slack_lambda_role.arn}"
  handler          = "lambda_function.lambda_handler"
  source_code_hash = "${base64sha256(file("terraform/lambda/lambda_cloudwatch_to_slack_opsgenie_payload.zip"))}"
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
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.cloudwatch_to_slack.arn}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.cloudwatch_alerts.arn}"
}

resource "aws_cloudwatch_metric_alarm" "cpu" {
  alarm_name          = "${var.project_name}-${var.environment}-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  alarm_description = "This metric monitors ec2 cpu utilization within the autoscaling group ${var.autoscaling_group_name}"
  alarm_actions     = ["${aws_sns_topic.cloudwatch_alerts.arn}"]
  ok_actions        = ["${aws_sns_topic.cloudwatch_alerts.arn}"]

  dimensions {
    AutoScalingGroupName = "${var.autoscaling_group_name}"
  }
}

resource "aws_cloudwatch_metric_alarm" "redis-cache-free-memory" {
  alarm_name          = "${var.project_name}-${var.environment}-redis-cache-free-memory"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = "120"
  statistic           = "Average"
  threshold           = "512000000"

  alarm_description = "This metric monitors the redis cache freeable memory for ${var.redis_cache_cluster_id}"
  alarm_actions     = ["${aws_sns_topic.cloudwatch_alerts.arn}"]
  ok_actions        = ["${aws_sns_topic.cloudwatch_alerts.arn}"]

  dimensions {
    CacheClusterId = "${var.redis_cache_cluster_id}"
  }
}

resource "aws_cloudwatch_event_rule" "code_pipeline_fail" {
  name        = "${var.project_name}-${var.environment}-code-pipeline-fail"
  description = "Notify on CodePipeline Failures"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.codepipeline"
  ],
  "detail-type": [
    "CodePipeline Pipeline Execution State Change"
  ],
  "detail": {
    "state": [
      "FAILED"
    ],
    "pipeline": [
      "${var.pipeline_name}"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "code_pipeline_fail_sns_target" {
  rule      = "${aws_cloudwatch_event_rule.code_pipeline_fail.name}"
  target_id = "CodePipeLineFail"
  arn       = "${aws_sns_topic.cloudwatch_alerts.arn}"
  input     = "{\"AlarmName\": \"Failed Pipeline\",\"NewStateValue\": \"SOFT_ALARM\",\"NewStateReason\": \"Pipeline ${var.pipeline_name} has failed\"}"
}

resource "aws_cloudwatch_event_rule" "code_pipeline_succeeded" {
  name        = "${var.project_name}-${var.environment}-code-pipeline-succeeded"
  description = "Notify on CodePipeline Success"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.codepipeline"
  ],
  "detail-type": [
    "CodePipeline Pipeline Execution State Change"
  ],
  "detail": {
    "state": [
      "SUCCEEDED"
    ],
    "pipeline": [
      "${var.pipeline_name}"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "code_pipeline_succeeded_sns_target" {
  rule      = "${aws_cloudwatch_event_rule.code_pipeline_succeeded.name}"
  target_id = "CodePipeLineSucceeded"
  arn       = "${aws_sns_topic.cloudwatch_alerts.arn}"
  input     = "{\"AlarmName\": \"Succeeded Pipeline\",\"NewStateValue\": \"SOFT_ALARM\",\"NewStateReason\": \"Pipeline ${var.pipeline_name} has succeeded :tada:\"}"
}
