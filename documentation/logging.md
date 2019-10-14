# Logging

## Application logs

Both web and worker services are configured to log out to our [Papertrail][papertrail] account.

[papertrail]: https://papertrailapp.com

## AWS CloudWatch

Inside our AWS account, London region, CloudWatch stores:

* CodeBuild logs.
* Lambda logs from the `cloudwatch_to_slack_opsgenie` function.
