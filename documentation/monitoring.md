# Monitoring and Logging

## Logging

### Application logs

- [Sidekiq](https://teaching-vacancies.service.gov.uk/sidekiq)
- [Check the Rollbar dashboard](https://rollbar.com/dfe/teacher-vacancies/) to see if any Errors are being logged.
- [Check the Logit event log](https://dashboard.logit.io/a/eeeb8311-79d8-49ab-9410-9b6d76b26f72) - Open Teaching Vacancy stack.

### Deployment logs

- [Check the GitHub Deploy workflow](https://github.com/DFE-Digital/teaching-vacancies/actions?query=workflow%3ADeploy) to see recent deployments.

## Monitoring, Metrics and Usage

### Grafana, Prometheus, and AlertManager

For several infrastructure components on Gov.UK PaaS, we use [Prometheus Exporters](https://prometheus.io/docs/instrumenting/exporters/) to:
- fetch statistics from another, non-Prometheus system
- turn those statistics into Prometheus metrics, using a client library
- expose a `/metrics` URL, and have that URL display the system metrics (in the case of teaching vacancies, rather than appending `/metrics` to the root URL, it's instead at [https://paas-prometheus-exporter-teaching-vacancies.london.cloudapps.digital/metrics](https://paas-prometheus-exporter-teaching-vacancies.london.cloudapps.digital/metrics))

- The [Teaching Vacancies Production Grafana dashboard](https://grafana-teaching-vacancies.london.cloudapps.digital/d/6Ac4lUWGk/teaching-vacancies-production?orgId=1&refresh=5s) has been set up with useful visualisations of metrics over time
- The [CF apps Grafana dashboard](https://grafana-teaching-vacancies.london.cloudapps.digital/d/eF19g4RZx/cf-apps?orgId=1&refresh=10s) allows the filtering of apps and spaces, so you could choose to see the performance of the `teaching-vacancies-worker-staging` app
- The [CF Databases dashboard](https://grafana-teaching-vacancies.london.cloudapps.digital/d/a2FR6FUMz/cf-databases?orgId=1&refresh=10s&var-SpaceName=teaching-vacancies-production&var-Services=teaching-vacancies-postgres-production) shows postgres metrics
- The [Redis dashboard](https://grafana-teaching-vacancies.london.cloudapps.digital/d/_XaXFGTMz/redis-dashboard-for-prometheus-redis-exporter-1-x?orgId=1&refresh=30s) shows metrics for all redis instances

- Additionally, we set up [Prometheus alerting rules](https://prometheus-teaching-vacancies.london.cloudapps.digital/alerts) (example: trigger when CPU usage goes above 60% for 5 minutes)
- [Alertmanager](https://alertmanager-teaching-vacancies.london.cloudapps.digital/#/alerts) receives the alerts specified in Prometheus, and routes these to the `#twd_tv_dev` channel in Slack

Alerts can be unit tested, which is very useful for non obvious changes. Use [promtool](https://prometheus.io/docs/prometheus/latest/configuration/unit_testing_rules/)
which is part of Prometheus and run `promtool test rules alert.test.yml` in the `terraform/monitoring/config` directory.

The stack is comprised of 4 apps in the Gov.UK `teaching-vacancies-monitoring` space:

- alertmanager-teaching-vacancies
- grafana-teaching-vacancies
- paas-prometheus-exporter-teaching-vacancies
- prometheus-teaching-vacancies

### Skylight

- [Report performance data with Skylight](https://www.skylight.io/app/applications/xsMWeSG9ned8/recent/6h/endpoints)

### StatusCake

- [Uptime check including test history](https://app.statuscake.com/UptimeStatus.php?tid=5636370) against `https://teaching-vacancies.service.gov.uk/check`

### PaaS

- [Check the Gov.UK PaaS `teaching-vacancies-production` space](https://admin.london.cloud.service.gov.uk/organisations/386a9502-d9b6-4aba-b3c3-ebe4fa3f963e/spaces/ebce88e9-8d3e-424b-8da3-c8dc0072b900/applications)

### Billing

- [Billing & Cost Management Dashboard](https://console.aws.amazon.com/billing/home#/) for which you'll need to first assume the AWS role [Billing Manager](https://console.aws.amazon.com/iam/home?region=eu-west-2#/roles/BillingManager)
- [PaaS statements](https://admin.london.cloud.service.gov.uk/organisations/386a9502-d9b6-4aba-b3c3-ebe4fa3f963e/statements) for which you'll need to be added to the Billing Role by `#digital-tools-support`
