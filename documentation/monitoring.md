# Monitoring and Logging

## Logging

### Application logs

- [Sidekiq](https://teaching-vacancies.service.gov.uk/sidekiq)
- [Check the Sentry dashboard](https://sentry.io/organizations/teaching-vacancies/issues) to see if any Errors are being logged.
- [Check the Logit event log](https://dashboard.logit.io) - Open Teaching Vacancy stack.

### Deployment logs

- [Check the GitHub Deploy workflow](https://github.com/DFE-Digital/teaching-vacancies/actions?query=workflow%3ADeploy) to see recent deployments.

## Monitoring, Metrics and Usage

### Skylight

- [Report performance data with Skylight](https://www.skylight.io/app/applications/xsMWeSG9ned8/recent/6h/endpoints)

### StatusCake

- [Uptime check including test history](https://app.statuscake.com/UptimeStatus.php?tid=5636370) against `https://teaching-vacancies.service.gov.uk/check`

### AKS

- Check the Teaching Vacancies `s189-teacher-services-cloud-production` [subscription resources](https://portal.azure.com/)

### Logs

- Azure logs can be accessed/queried from the Azure Long resources `s189p01-tv-pd-rg` under `s189-teacher-services-cloud-production` subscription.


**Outdated:** For the moment, AKS logs are not sent to Logit. There are plans to change this in the future.

PaaS logs are drained to logit. There are customised alerts on Logit, which monitors and alerts on various events.

`alert_on_no_logs_from_paas.yaml`: This monitors and alerts if no logs are being sent from PaaS to Teaching-Vacanices' Logit stack.
`Throttled.yml`: This monitors and alerts if we have unusual amount of requests, which have been throttled.

### Billing

- [Billing & Cost Management Dashboard](https://console.aws.amazon.com/billing/home#/) for which you'll need to first assume the AWS role [Billing Manager](https://console.aws.amazon.com/iam/home?region=eu-west-2#/roles/BillingManager)
- [Hosting Billing](https://portal.azure.com/?feature.msaljs=true#view/Microsoft_Azure_Billing/SubscriptionsBladeV1) accessed through the DFE Platform Identity subscriptions in Azure.
