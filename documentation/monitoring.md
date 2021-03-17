# Monitoring and Logging

## Logging

### Application logs

- [Sidekiq](https://teaching-vacancies.service.gov.uk/sidekiq)
- [Check the Rollbar dashboard](https://rollbar.com/dfe/teacher-vacancies/) to see if any Errors are being logged.
- [Check the Papertrail event log](https://papertrailapp.com/events) to see in real-time if any Errors are being logged.

### Deployment logs

- [Check the GitHub Deploy workflow](https://github.com/DFE-Digital/teaching-vacancies/actions?query=workflow%3ADeploy) to see recent deployments.

## Monitoring, Metrics and Usage

### Grafana, Prometheus, and AlertManager

For several infrastructure components on Gov.UK PaaS, we use [Prometheus Exporters](https://prometheus.io/docs/instrumenting/exporters/) to:
- fetch statistics from another, non-Prometheus system
- turn those statistics into Prometheus metrics, using a client library
- expose a `/metrics` URL, and have that URL display the system metrics (in the case of teaching vacancies, rather than appending `/metrics` to the root URL, it's instead at [https://paas-prometheus-exporter-teaching-vacancies.london.cloudapps.digital/metrics](https://paas-prometheus-exporter-teaching-vacancies.london.cloudapps.digital/metrics))

The [Teaching Vacancies Production Grafana dashboard](https://grafana-teaching-vacancies.london.cloudapps.digital/d/6Ac4lUWGk/teaching-vacancies-production?orgId=1&refresh=5s) has been set up with useful visualisations of metrics over time for:
- Requests per minute to the web app
- Average CPU usage for the web app and the worker app
- Max memory usage for the web app and the worker app

The [CF apps Grafana dashboard](https://grafana-teaching-vacancies.london.cloudapps.digital/d/eF19g4RZx/cf-apps?orgId=1&refresh=10s) allows the filtering of apps and spaces, so you could choose to see the performance of the `teaching-vacancies-worker-staging` app

- Additionally, we set up [Prometheus alerting rules](https://prometheus-teaching-vacancies.london.cloudapps.digital/alerts) (to trigger when CPU usage goes above 60% for 5 minutes)
- [Alertmanager](https://alertmanager-teaching-vacancies.london.cloudapps.digital/#/alerts) receives the alerts specified in Prometheus, and routes these to the `#twd_tv_dev` channel in Slack

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
