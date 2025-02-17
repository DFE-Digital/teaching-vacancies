# Monitoring and Logging

## Logging

### Application logs

- [Sidekiq](https://teaching-vacancies.service.gov.uk/sidekiq)
- [Check the Sentry dashboard](https://sentry.io/organizations/teaching-vacancies/issues) to see if any Errors are being logged.
- [Check the Logit event log](https://dashboard.logit.io) - Open Teaching Vacancy stack.

### Deployment logs

- [Check the GitHub Deploy workflow](https://github.com/DFE-Digital/teaching-vacancies/actions?query=workflow%3ADeploy) to see recent deployments.

## Monitoring, Metrics and Usage

### Grafana Dashboards

- [TV roduction namespace dashboard](https://grafana.teacherservices.cloud/d/k8s_views_ns/kubernetes-views-namespaces?orgId=1&refresh=10s&var-datasource=P5DCFC7561CCDE821&var-cluster=prometheus&var-namespace=tv-production&var-resolution=30s&var-created_by=All&from=now-3h&to=now)
- [TV production pods dashboard](https://grafana.teacherservices.cloud/d/k8s_views_pods/kubernetes-views-pods?orgId=1&refresh=10s&var-datasource=P5DCFC7561CCDE821&var-cluster=prometheus&var-namespace=tv-production&var-deployment=All&var-pod=All&var-resolution=30s&from=now-3h&to=now)

### Skylight

- [Report performance data with Skylight](https://www.skylight.io/app/applications/xsMWeSG9ned8/recent/6h/endpoints)

### StatusCake

- [Uptime check including test history](https://app.statuscake.com/UptimeStatus.php?tid=5636370) against `https://teaching-vacancies.service.gov.uk/check`

### AKS

- Check the Teaching Vacancies `s189-teacher-services-cloud-production` [subscription resources](https://portal.azure.com/)

### Logs

- Azure logs can be accessed/queried from the Azure Long resources `s189p01-tv-pd-rg` under `s189-teacher-services-cloud-production` subscription.


For the moment, AKS logs are not sent to Logit. There are plans to change this in the future.


### Billing

- [Billing & Cost Management Dashboard](https://console.aws.amazon.com/billing/home#/) for which you'll need to first assume the AWS role [Billing Manager](https://console.aws.amazon.com/iam/home?region=eu-west-2#/roles/BillingManager)
- [Hosting Billing](https://portal.azure.com/?feature.msaljs=true#view/Microsoft_Azure_Billing/SubscriptionsBladeV1) accessed through the DFE Platform Identity subscriptions in Azure.
