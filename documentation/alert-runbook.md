# Alert Runbook

These alerts are related to the service servers and raised by Prometheus in the [#twd_tv_dev](https://ukgovernmentdfe.slack.com/archives/CP987RP6J) Slack channel.

Alerts are defined/configured in [this configuration file](../terraform/monitoring/config/alert.rules.yml).


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
- [Check the DFE Azure  `tv-production` namespace in `s189-teacher-services-cloud-production` cluster](https://portal.azure.com/#home)

### Azure Kubernetes Service (AKS)

Further information on setting up and logging in to `AKS` are in the [hosting](../hosting.md) document.

- Request editor role access to `s189-teacher-services-cloud-production` subscription throguh the [Azure Portal](https://portal.azure.com/#home)
- Login with `az login --tenant tenantid`
- List apps with `kubectl get deployments -n tv-production` (or other desired namespace)
- List apps pods statuses for the  namespace with `kubectl get deployments -n tv-production`
- Get the logs for the app
```bash
make production logs CONFIRM_PRODUCTION=YES
```
- Restart apps with 
  ```
  kubectl rollout restart deployment teaching-vacancies-production -n tv-production
  kubectl rollout restart deployment teaching-vacancies-production-worker -n tv-production
  ``````


### Terraform

Most AKS settings are in [production.tfvars.json](../terraform/workspace-variables/production.tfvars.json)

```
postgres_flexible_server_sku      = "GP_Standard_D2ds_v4"
postgres_enable_high_availability = true
redis_queue_sku_name              = "Premium"
aks_web_app_instances             = 8
paas_worker_app_instances         = 4
aks_worker_app_memory             = "1.5Gi"
```

### Apps

Scale out the number of instances by increasing:

- `aks_web_app_instances`
- `paas_worker_app_instances`

Scale up the worker app memory by increasing:

- `aks_worker_app_memory` (the default for app memory is set to 1Gi in [variables.tf](../terraform/app/variables.tf), and then overridden for the worker app in production only.

#### Postgres

You can list the computing and storage options for the [Postgres flexible server](https://learn.microsoft.com/en-gb/azure/postgresql/flexible-server/overview) instances from [this list](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-compute-storage)

Change the value for `postgres_flexible_server_sku`.

#### Redis

From [Azure Cache for Redis documentation](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/)

You can list the different Redis Cache tiers in [this page](https://azure.microsoft.com/en-us/pricing/details/cache/)

Change the value for `redis_queue_sku_name`, `redis_queue_family` and `redis_queue_capacity`. Same for `redis_cache_` values. 
