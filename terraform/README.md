# Terraform

This terraform configuration will create an AWS stack.

Resources included:
- CodePipeline
- CodeBuild
- CodeDeploy
- ECR Docker registry
- CloudFront
- VPC, 2 public subnets, 2 private subnets in 2 availability zones
- Postgres via RDS
- ElasticSearch
- CloudWatch
- EC2 instances
- Autoscaling configuration

## Setup an environment

1. Create 2 certificates:
    1. CloudFront: Request an SSL certificate with AWS Certificate Manager in the 'N. Virginia (us-east-1)' region.
    2. ALB: Request an SSL certificate with AWS Certificate Manager in the region in which you are launching the infrastructure. eg eu-west-2

2. Find or create the Bucket that will store the state of Terraform. Go to S3 and create a bucket with a globally unique name:

Ensure the bucket has the following policy, adding more or less users as required:
```
{
    "Version": "2008-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<AWS ACCOUNT ID>:user/<USER NAME>"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::<INSERT PROJECT NAME>"
        },
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::<AWS ACCOUNT ID>:user/<USER NAME>"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::<INSERT PROJECT NAME>/staging/terraform.tfstate",
                "arn:aws:s3:::<INSERT PROJECT NAME>/production/terraform.tfstate"
            ]
        }
    ]
}
```

3. Copy across the variable template from workspace-variables

```
$ cp workspace-variables/staging.tfvars.example workspace-variables/staging.tfvars
$ cp workspace-variables/production.tfvars.example workspace-variables/production.tfvars
```

4. Initialise Terraform
For the first time you are working with Terraform you'll need to run:
```
$ terraform init
```

5. Create the and select the correct workspaces

  Workspaces allow the Terraform commands to be run with different states, giving them a degree of isolation. Eg. you can create a test workspace

```
$ terraform workspace create staging
$ terraform workspace create production
$ terraform workspace select staging
```

6. Plan what Terraform will do to ensure there are no errors

```
$ terraform plan -var-file=workspace-variables/staging.tfvars
```

7. Apply Terraform changes
```
$ terraform apply -var-file=workspace-variables/staging.tfvars
```

## Setup a testing pipeline

To enable CI to give us test feedback on our GitHub pull requests we can do a small piece of manual set up:

1. Create a new CodeBuild project in AWS
2. Name it eg. `tvs2-pull-requests`. You can call it anything you like but bear in mind it is not environment or workspace related, there's one per repository
3. Connect it to your GitHub repository
4. Set Git clone depth to `1`
5. Ensure `Rebuild every time a code change is pushed to this repository` is ticked
6. Tick `Use an image managed by AWS CodeBuild`
7. Select `Ubuntu` for OS
8. Select `Docker` for Runtime
9. Tick `Enable this flag if you want to build Docker images or want your builds to get elevated privileges.`
10. Select `Use the buildspec.yml in the source code root directory`
11. Provide the file name for what the CodeBuild process should run, ours is in `testspec.yml` and is a subset of `buildspec.yml`
12. Select `Do not install any certificate`
13. Select `No artifacts` from the drop down
14. Select `No cache` from the drop down
15. Select `Create a service role in your account`
16. Select `No VPC`
17. Open advanaced settings
18. Lower the build timeout from 1 hour to 15 minutes

## CloudWatch Alerts

The `cloudwatch_slack_hook_url` and `cloudwatch_ops_genie_api_key` variables need to be in an encrypted and base64 encoded format. There currently isn't a way to do this with Terraform, so to work around this:

1. Set them as their clear text values and apply
2. Go to the Lambda function settings within the AWS Console
3. Under 'Environment Variables', expand 'Encryption configuration' and select 'Enable helpers for encryption in transit'
4. Select the 'tvs2-\<env\>-cloudwatch-lambda' key
5. Select 'Encrypt' on both the `opsGenieApiKey` and `slackHookUrl`
6. Click 'Save'
7. Reload the page, and copy both of the (now encrypted) values, and replace `cloudwatch_slack_hook_url` and `cloudwatch_ops_genie_api_key` in your variables file.
8. Run a terraform plan to ensure everything has been done correctly (You should not have any changes required for the lambda resource)

## Being offline

We are using a combination of AWS CloudFront and S3 to serve users a self-contained static page that can be found here https://github.com/dxw/school-jobs-offline. CloudFront has been configured through Terraform to detect 503 'Service Unavailable' or 502 'Bad Gateway' responses that occur downstream in our stack and will handle those requests by responding with content from the bucket.

This allows for our servers or containers to be turned off intentionally or fail unintentionally whilst ensuring a our service fails gracefully, with expectations set with the user.

If we wished to turn force the service into this offline mode we can set the desired container count to 0 through Terraform.

The way this can fail is that either AWS CloudFront, AWS S3 or our configuration of the 2 becomes non functional. Should AWS experience such a fundamental failure we might consider recovering from that situation by moving the static content to a new provider and updating the DNS.

### Setup

Without this setup, CloudFront will continue to provide generic 503 and 502 pages.

1. Create a new S3 bucket and set the access permissions to public, this value will correspond to: `offline_bucket_domain_name`
2. Add your static content to a new directory that corresponds to, making sure they are all set to public too: `offline_bucket_origin_path`
3. The file that will be rendered is currently `index.html`

## Add new environment variables

Our application environment variables are defined and used in multiple places. We try to group the variables in the
same way in each file to reduce cognitive effort for future readers.

1. `docker-compose.env.sample` - In the application’s sample env file
1. `variables.tf` - At the bottom under 'Application variables'
1. `terraform.tf` - In the ECS module
1. `web_container_definition.json` - Add entry to the `environment` array
1. `terraform/modules/ecs/input.tf` - In the ECS module input contract
1. `terraform/modules/ecs/ecs.tf` - In the ECS module web container definition
1. `workspace-variables/<env>.tfvars` - In each workspace tfvars
1. `workspace-variables/workspace.tfvars.example` - In the example workspace tfvars
1. Sync workspace tfvars to 1password for the team


### Configuring a rake task

In `terraform.tf` add a task command and a relevant schedule for tasks that need to be executed automatically  on a time schedule

```
  <task_name>_task_command    = "${var.<task_name>_submit_task_command}"
  <task_name>_task_schedule   = "${var.<task_name>_submit_task_schedule}"
```

In `terraform/modules/ecs/ecs.tf` add a new task definition. All variables specified below are required **but** if your task is making use of other variables, make sure you specify them within the vars block as well.

```
/* <task_name> task definition*/
data "template_file" "<task_name>_submit_container_definition" {
  template = "${file(var.ecs_service_rake_container_definition_file_path)}"
  vars {
    image                    = "${aws_ecr_repository.default.repository_url}"
    secret_key_base          = "${var.secret_key_base}"
    project_name             = "${var.project_name}"
    task_name                = "${var.ecs_service_web_task_name}_<task_name>"
    environment              = "${var.environment}"
    rails_env                = "${var.rails_env}"
    region                   = "${var.region}"
    log_group                = "${var.aws_cloudwatch_log_group_name}"
    database_user            = "${var.rds_username}"
    database_password        = "${var.rds_password}"
    database_url             = "${var.rds_address}"
    elastic_search_url       = "${var.es_address}"
    aws_elasticsearch_region = "${var.aws_elasticsearch_region}"
    aws_elasticsearch_key    = "${var.aws_elasticsearch_key}"
    aws_elasticsearch_secret = "${var.aws_elasticsearch_secret}"
    entrypoint               = "${jsonencode(var.<task_name>_task_command)}"

    # other task specific env variables

  }
}
```

#### Environment variables for rake tasks

When adding new environment variables you need to define the variables in the task's container definition JSON file.

1. `cp rake_container_definition.json <identifier>_rake_container_definition.json` Create a copy of the existing rake container definition
2. Set the new variables

  ```
  {
    "name": "NEW_ENV_VARIABLE",
    "value": "${new_env_variable}"
  }
  ```
3. Add a new entry for the file in `variables.tf` under **Rake task container definitions**

  ```
  variable "<identifier>_container_definition_file_path" {
    description = "Container definition for <identifier> rake tasks"
    default     = "./<identifier>_rake_container_definition.json"
  }
  ```

4. Add a new variable in `terraform/modules/ecs/input.tf` under **Rake task container definitions**

  ```
  variable "<identifier>_rake_container_definition_file_path" {}
  ```

5. Add a new entry in the `ecs` module in `terraform.tf`

  ```
  <identifier>_rake_container_definition_file_path = "${var.<identifier>_rake_container_definition_file_path}"
  ```

6. Update the template value in the task definition in `terraform/modules/ecs/ecs.tf` to point to the new template

  ```
  template = "${file(var.<identifier>_rake_container_definition_file_path)}"
  ```



#### One-off and scheduled tasks


If your task is one-off (only manually executed) add an entry under `ECS ONE-OFF TASKS` for the aws task definition

```
  resource "aws_ecs_task_definition" "<task_name>_task" {
  family                   = "${var.ecs_service_web_task_name}_<task_name>_task"
  container_definitions    = "${data.template_file.<task_name>_container_definition.rendered}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  execution_role_arn       = "${aws_iam_role.ecs_execution_role.arn}"
  task_role_arn            = "${aws_iam_role.ecs_execution_role.arn}"
}
```

For scheduled tasks add both the entry from above under `ECS SCHEDULED TASKS` and along with that specify an aws_clouwatch event rule and target

```
resource "aws_cloudwatch_event_rule" "<task_name>" {
  name                = "${var.ecs_service_web_task_name}_<task_name>_task"
  description         = "Run <task_name> at a scheduled time"
  schedule_expression = "${var.<task_name>_schedule}"
}

resource "aws_cloudwatch_event_target" "<task_name>_task_event" {
  target_id = "${var.ecs_service_web_task_name}_<task_name>"
  rule      = "${aws_cloudwatch_event_rule.<task_name>_task.name}"
  arn       = "${aws_ecs_cluster.cluster.arn}"
  role_arn  = "${aws_iam_role.scheduled_task_role.arn}"

  ecs_target {
    task_count          = "1"
    task_definition_arn = "${aws_ecs_task_definition.<task_name>_task.arn}"
  }
}
```
