# Monitoring and Logging

## Logging

### Application logs

- [The Logit dashboard](https://dashboard.logit.io/a/7ef698e1-d0ae-46c6-8d1e-a1088f5e034e) gives us access to the logs in Kibana for different stacks:
  - For Production logs, the stack is `TEACHER SERVICES CLOUD PRODUCTION`
  - For other environments (review, QA, Staging), the stack is `TEACHER SERVICES CLOUD TEST`

#### Filtering logs in Kibana
  - Filter the app and environment. Add and PIN a filter with:
    - Field: `kubernetes.deployment.name`
    - Operator: `is`
    - Value: `teaching-vacancies-production` / `teaching-vacancies-staging` / `teaching-vacancies-qa` / `teaching-vacancies-review-pr-xxxx`
  - If filtering particular routes, you can filter by the URL path:
    - Field: `url.path`
    - Value: (EG For the ATS API) `/ats-api/v1/vacancies`
  - To remove the noise and focus the logs in the relevant info. You can specify the "Selected fields" in the left bar. Some useful fields to include in the log results:
    - `app.message`
    - `app.payload.params_json`
    - `url.path`
    - `app.payload.status_message`
  - You can also filter the logs by particular field values.
  - If you don't see expected results. Be sure the time window of the logs is big enough, as it defaults to the last 15 minutes.

### Deployment logs

- [Check the GitHub Deploy workflow](https://github.com/DFE-Digital/teaching-vacancies/actions?query=workflow%3ADeploy) to see recent deployments.

## Monitoring, Metrics and Usage

### Error monitoring

- [Check the Sentry dashboard](https://teaching-vacancies.sentry.io/issues/?environment=production&project=6212514&statsPeriod=7d) to see if any Errors are being logged.

### Background jobs

- [The Sidekiq dashboard](https://teaching-vacancies.service.gov.uk/sidekiq) allows us to monitor and trigger background and scheduled jobs.

### Grafana Dashboards

- [TV roduction namespace dashboard](https://grafana.teacherservices.cloud/d/k8s_views_ns/kubernetes-views-namespaces?orgId=1&refresh=10s&var-datasource=P5DCFC7561CCDE821&var-cluster=prometheus&var-namespace=tv-production&var-resolution=30s&var-created_by=All&from=now-3h&to=now)
- [TV production pods dashboard](https://grafana.teacherservices.cloud/d/k8s_views_pods/kubernetes-views-pods?orgId=1&refresh=10s&var-datasource=P5DCFC7561CCDE821&var-cluster=prometheus&var-namespace=tv-production&var-deployment=All&var-pod=All&var-resolution=30s&from=now-3h&to=now)

### Skylight

- [Report performance data with Skylight](https://www.skylight.io/app/applications/xsMWeSG9ned8/recent/6h/endpoints)

### StatusCake

- [Uptime check including test history](https://app.statuscake.com/UptimeStatus.php?tid=5636370) against `https://teaching-vacancies.service.gov.uk/check`

### AKS

- Check the Teaching Vacancies `s189-teacher-services-cloud-production` [subscription resources](https://portal.azure.com/)


### Billing

- [Billing & Cost Management Dashboard](https://console.aws.amazon.com/billing/home#/) for which you'll need to first assume the AWS role [Billing Manager](https://console.aws.amazon.com/iam/home?region=eu-west-2#/roles/BillingManager)
- [Hosting Billing](https://portal.azure.com/?feature.msaljs=true#view/Microsoft_Azure_Billing/SubscriptionsBladeV1) accessed through the DFE Platform Identity subscriptions in Azure.
