# Alert Runbook

## ProdRequestsFailuresElevated

Alerts when `teaching-vacancies-production` app has a rate of more than 10% of requests failing for a 5-minute period.
Failed requests are defined as those with HTTP status codes matching the patterns `0xx`, `4xx` or `5xx`.

## ProdAppCPUHigh

Alerts when the `teaching-vacancies-production` app has an average CPU usage above 60% for a 5-minute period.

## ProdWorkerCPUHigh

Alerts when the `teaching-vacancies-worker-production` app has an average CPU usage above 75% for a 10-minute period.

## ProdDiskUtilizationHigh

Alerts when either the `teaching-vacancies-production` or `teaching-vacancies-worker-production` app has an average Disk utilization above 60% for a 5-minute period.

## ProdMemoryUtilizationHigh

Alerts when either the `teaching-vacancies-production` or `teaching-vacancies-worker-production` app has an average Memory utilization above 60% for a 5-minute period.

## ProdAppsCrashed

Alerts when either the `teaching-vacancies-production` or `teaching-vacancies-worker-production` app reports a crash.

## ProdSlowRequests

Alerts when the `teaching-vacancies-production` app http response time is slow.

## Action

### Metrics and Logging

- [Check the Grafana panel](https://grafana-teaching-vacancies.london.cloudapps.digital/d/6Ac4lUWGk/teaching-vacancies-production?orgId=1&refresh=5s) to see this alert in the context of all the metrics.
- [Check the Sentry dashboard](https://sentry.io/organizations/teaching-vacancies/issues) to see if any Errors are being logged.
- [Check the Logit event log](https://dashboard.logit.io) to see in real-time if any Errors are being logged.
- [Check the GitHub Deploy workflow](https://github.com/DFE-Digital/teaching-vacancies/actions?query=workflow%3ADeploy) to determine if any recent deployments may have caused the issue.
- [Check the Gov.UK PaaS `teaching-vacancies-production` space](https://admin.london.cloud.service.gov.uk/organisations/386a9502-d9b6-4aba-b3c3-ebe4fa3f963e/spaces/ebce88e9-8d3e-424b-8da3-c8dc0072b900/applications)

### CloudFoundry

Further information on setting up and logging in to CloudFoundry are in the [hosting](../hosting.md) document.

- Login with `cf login --sso`
- Choose `teaching-vacancies-production` from the numeric menu.
- List apps with `cf apps`.
- Check if any apps are crashed (e.g. `processes` may list 3 of 4 apps running: `web:3/4`)
- Get the logs for the app
```bash
cf logs teaching-vacancies-production
```
- Restart apps with `cf restart <app_name> --strategy rolling`

### Terraform

Most PaaS settings are in [production.tfvars.json](../terraform/workspace-variables/production.tfvars.json)

```
paas_postgres_service_plan             = "medium-ha-11"
paas_redis_service_plan                = "small-ha-4_x"
paas_web_app_instances                 = 4
paas_worker_app_instances              = 2
paas_worker_app_memory                 = 1536
```

### Apps

Scale out the number of instances by increasing:

- `paas_web_app_instances`
- `paas_worker_app_instances`

Scale up the worker app memory by increasing:

- `paas_worker_app_memory` (the default for app memory is set to 512M in [variables.tf](../terraform/app/paas/variables.tf), and then overridden for the worker app in production only.

#### Postgres

From [Set up a PostgreSQL service](https://docs.cloud.service.gov.uk/deploying_services/postgresql/#set-up-a-postgresql-service)
> Run the following code in the command line to see what plans are available for PostgreSQL:
```bash
cf marketplace -e postgres
```

Choose a plan which is
- Highly-available (`ha`)
- The same PostgreSQL version number (e.g. `12`) plan

Change the value for `paas_postgres_service_plan`.

#### Redis

From [Set up a Redis service](https://docs.cloud.service.gov.uk/deploying_services/redis/#set-up-a-redis-service)
> Run the following code in the command line to see what plans are available for Redis:
```bash
cf marketplace -e redis
```

Choose a plan which is
- Highly-available (`ha`)
- The same Redis version number (e.g. `5.x`) plan

Change the value for `paas_redis_service_plan`. Note that the `5.x` plans use an underscore rather than a dot (e.g. `small-ha-5_x`).
