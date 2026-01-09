# Infrastructure diagrams

## CI/CD deployment pipeline

On Pull Request to `main` branch, GitHub Actions `deploy.yml` workflow launches:

```mermaid
flowchart TD

Developer((Developer))

Developer --> |PR to main branch on https://github.com/DFE-Digital/teaching-vacancies|GitHubMaster(GitHub main branch)
GitHubMaster --> |Start GitHub Actions Workflow and Ubuntu Virtual Environment| GitHubVirtualEnv(GitHub virtual environment)
GitHubVirtualEnv --> |Decode AWS secrets<br />Check for well-formed YAML| AWSSSMParameterStore[AWS SSM Parameter Store]
GitHubVirtualEnv --> |Initialise Terraform |GitHubVirtualEnvPlusTerraform(Terraform CLI on GitHub virtual environment)
GitHubVirtualEnv --> |Decode GitHub Secrets|GitHubSecrets(GitHub Secrets)
GitHubVirtualEnv --> |Build Docker image<br />Push to DockerHub| DockerHub
GitHubVirtualEnvPlusTerraform --> |Decode AWS secrets<br />Create env vars| AWSSSMParameterStore[AWS SSM Parameter Store]
GitHubVirtualEnvPlusTerraform --> |Create/Update| AWSCloudfront[AWS Cloudfront Distribution]
GitHubVirtualEnvPlusTerraform --> |Create/Update| Statuscake{Statuscake rule}
GitHubVirtualEnvPlusTerraform --> |Create/Update| AzureServices(Azure services:<br>PostgreSQL<br>Redis)
GitHubVirtualEnvPlusTerraform --> |Create/Update| AzureApps(Azure apps<br>and web route)
DockerHub --> |Pull Docker tagged image| AzureApps

click GitHubMaster "https://github.com/DFE-Digital/teaching-vacancies" "Github Main branch" _blank
```


## Web visit
```mermaid
flowchart TD

EndUser((End user))

EndUser --> |Browse to https://teaching-vacancies.service.gov.uk|Route53[Route53]
Route53 --> |Alias A record| Cloudfront
Cloudfront --> |Record Standard Logs|S3cloudfrontlogs[S3 bucket: `cloudfrontlogs`]
Cloudfront --> |Cache static assets|SiteOnline{Azure site online?}
Cloudfront --> ACMCertificate[AWS-issued certificate]
SiteOnline -->|No| OfflineURI[Serve Offline pages]
OfflineURI -->|https://tvs-offline.s3.amazonaws.com/school-jobs-offline/index.html|S3offline[S3 bucket `tvs-offline`]
SiteOnline -->|Yes| Azure[CDN to Azure web app]
Azure -->|https://teaching-vacancies-production.teacherservices.cloud|AzureWeb(Azure web app)

click OfflineURI "https://tvs-offline.s3.amazonaws.com/school-jobs-offline/index.html" "Offline static site" _blank
click AzureWeb "https://teaching-vacancies-production.teacherservices.cloud" "Azure web" _blank
```

## Mermaid.js

Diagrams generated with [Mermaid.js](https://mermaid-js.github.io/mermaid/#/)

Preview with [Markdown Preview Mermaid Support](https://marketplace.visualstudio.com/items?itemName=bierner.markdown-mermaid)

