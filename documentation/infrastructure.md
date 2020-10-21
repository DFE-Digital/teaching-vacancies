# Infrastructure diagrams

## CI/CD deployment pipeline

On Pull Request to `master` branch, GitHub Actions `deploy.yml` workflow launches:

```mermaid
graph TD

Developer((Developer))

Developer --> |PR to master branch on https://github.com/DFE-Digital/teacher-vacancy-service|GitHubMaster(GitHub master branch)
GitHubMaster --> |Start GitHub Actions Workflow and Ubuntu Virtual Environment| GitHubVirtualEnv(GitHub virtual environment)
GitHubVirtualEnv --> |Decode AWS secrets<br />Check for well-formed YAML| AWSSSMParameterStore[AWS SSM Parameter Store]
GitHubVirtualEnv --> |Initialise Terraform |GitHubVirtualEnvPlusTerraform(Terraform CLI on GitHub virtual environment)
GitHubVirtualEnv --> |Decode GitHub Secrets|GitHubSecrets(GitHub Secrets)
GitHubVirtualEnv --> |Build Docker image<br />Push to DockerHub| DockerHub
GitHubVirtualEnvPlusTerraform --> |Decode AWS secrets<br />Create env vars| AWSSSMParameterStore[AWS SSM Parameter Store]
GitHubVirtualEnvPlusTerraform --> |Create/Update| AWSCloudfront[AWS Cloudfront Distribution]
GitHubVirtualEnvPlusTerraform --> |Create/Update| Statuscake{Statuscake rule}
GitHubVirtualEnvPlusTerraform --> |Create/Update| GovUKPaaSServices(-Gov.UK PaaS services <br />PostgreSQL<br />Redis<br />Papertrail-)
GitHubVirtualEnvPlusTerraform --> |Create/Update| GovUKPaaSApps(-Gov.UK PaaS apps <br />and web route-)
DockerHub --> |Pull Docker tagged image| GovUKPaaSApps

```

## Web visit

```mermaid
graph TD

EndUser((End user))

EndUser --> |Browse to https://teaching-vacancies.service.gov.uk|Route53[Route53]
Route53 --> |Alias A record| Cloudfront
Cloudfront --> |Record Standard Logs|S3cloudfrontlogs[S3 bucket: `cloudfrontlogs`]
Cloudfront --> |Cache static assets|SiteOnline{PaaS site online?}
Cloudfront --> ACMCertificate[AWS-issued certificate]
SiteOnline -->|No| OfflineURI[Serve Offline pages]
OfflineURI -->|https://tvs-offline.s3.amazonaws.com/school-jobs-offline/index.html|S3offline[S3 bucket `tvs-offline`]
SiteOnline -->|Yes| PaaS[CDN to Gov.UK PaaS]
PaaS -->|https://teaching-vacancies-production.london.cloudapps.digital|Gov.UKPaaS(-Gov.UK PaaS-)

```

## Key

- Circle - End user
- Diamond - Third parties other than AWS and GitHub 
- Ellipse - Gov.UK PaaS
- Rectangle - AWS
- Rounded rectangle - GitHub

## Mermaid.js

Diagram generated with [Mermaid.js](https://mermaid-js.github.io/mermaid/#/)

Preview with [Markdown Preview Mermaid Support](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid)

From [diagrams.net](https://www.diagrams.net/blog/mermaid-diagrams)
```
((circle))
{diamond}
(-ellipse-)
[rectangle]
(rounded rectangle)
```
