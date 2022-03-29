# Deploy, update, and remove environments

## Build and deploy

### Build and deploy - GitHub Actions

The deployments to all environments share the same and simplified workflow. The deployment to review app (via Pull Request), staging, production, and qa go through the CI/CD pipeline. To deploy to `Dev` environment, a `git push local_branch_name:dev -f` is required to commence deployment. This will trigger the same workflows as used in deploying to other environment.

Once the PR has been merged to main or a `deploy`tag applied to Review app or `git push` to dev branch:-

The GitHub actions workflow [build_and_deploy.yml](../.github/workflows/build_and_deploy.yml) performs these steps:

- Builds and tags a Docker image from code in the `main` (staging, prod, and qa environments), `Dev` or `review app` branch
- Tags the Docker image with the commit SHA as the tag
- Logs in to Github's container registry as the service account `twd-tv-ci`
- Pushes the image to GitHub packages, after it has been scanned by `Snyk` for vulnerabilities
- Calls the [deploy_app.yml](../.github/workflows/deploy_app.yml) workflow to use Terraform to update the `web` and `worker` apps to use the new Docker image, and apply any changes to the appropriate environment.
- Runs a smoke test against the deployed environment
- If deployment (push) is to the main branch, performs `Post Deployment` step e.g. deploy terraform/monitoring module, which is responsible for deploying Prometheus, influxDB and Grafana.
- Sends a Slack notification to the `#twd_tv_dev` channel - success or failure.

### Build and deploy to review - GitHub Actions

Perform the following to trigger a deployment a review app

- Push to a feature branch.
- Create a Pull Request.
- attach a `deploy` label
- Docker image and tag used to deploy the `review app` is based on the review app's `branch` and `sha` e.g teva-1234:commit_sha


### Merge and concurrency deployment management
When there are multiple merges, this could lead to race conditions. To mitigate this, the `turnstyle` action prevents two or more instances of the same workflow from running concurrently.

Furthermore, to help with workflow code reuse, we trigger a separate deployment workflow via the [workflow_dispatch](https://docs.github.com/en/actions/reference/events-that-trigger-workflows#workflow_dispatch) action. We must pass the `ref` (branch) or pull request `ref` to locate the workflow.

To block the calling workflow until the triggered workflow is completed, we use `action-wait-for-check`. This checks and waits on a `sha` (commit) instead of `ref` (branch), which is a moving target.


### Refresh cached docker image: `ghcr.io/dfe-digital/teaching-vacancies:main`

Refresh the cached `ghcr.io/dfe-digital/teaching-vacancies:main` image on Github packages. In case the build workflow fails at the `Scan ghcr.io/dfe-digital/teaching-vacancies:main image` stage, it may be that a fix is available but our cache is stale; with the vulnerable dependency. In this case use the [rebuild_docker_cache_workflow](../.github/workflows/rebuild_docker_cache.yml) to refresh the cache with updated packages. The rebuild_docker_cache_workflow is scheduled on a weekly run (12 noon on Sundays) and can also be triggered manaully via workflow dispatch.


### Build and deploy to an environment - Makefile

This builds and deploys a Docker image from local code, then updates the environment to use that image

Note: Automated deployments via GitHub Actions workflows as outlined above are recommended in preference to this more manual approach below.

```bash
make passcode=<passcode> <environment> deploy-local-image
```
performs these steps:

- Builds and tags a Docker image from local code
- Pushes the image to Docker Hub
- Uses Terraform to apply any changes (including providing the tag of the Docker image) to the environment

Requirements:
- docker CLI of at least version `19.03`
- [terraform CLI](https://www.terraform.io/downloads.html) of at least version `1.0.8`
- Write access to Docker Hub `dfedigital/teaching-vacancies` repository. Ask in #digital-tools-support should you require it.
- Log in to Container registry (with `docker login ghcr.io -u USERNAME` - use PAT token as passoword)
- Log in to GOV.UK PaaS (with `cf login --sso`). You will need a [Passcode](https://login.london.cloud.service.gov.uk/passcode)


## Deploy a pre-built image

### Default tag

If no docker image tag is specified, the makefile defaults to using the `main` tag - as specified in the makfile's `terraform-app-init:` target

### Deploy a specific tag to an environment - GitHub Actions

If you need to deploy a particular image to an environment, including in a rollback situation, this is possible with the [deploy_app.yml](/.github/workflows/deploy_app.yml) workflow.

You will need to know the tag of the Docker image you wish to use. Go to the [Github packages](https://github.com/DFE-Digital/teaching-vacancies/pkgs/container/teaching-vacancies)

E.g. [image tag 2641bebaf22ad96be543789693e015922e4514c4](https://hub.docker.com/layers/dfedigital/teaching-vacancies/2641bebaf22ad96be543789693e015922e4514c4/images/sha256-804c11e347b156a65c4ffe504e11e97917550d3ea11fed4e1697fdfc3725f3f7?context=explore)
is built from [commit 2641bebaf22ad96be543789693e015922e4514c4](https://github.com/DFE-Digital/teaching-vacancies/commit/2641bebaf22ad96be543789693e015922e4514c4)

Go to the [Deploy App to Environment](https://github.com/DFE-Digital/teaching-vacancies/actions?query=workflow%3A%22Deploy+App+to+Environment%22) workflow.
Click "Run workflow", and choose:
- Use workflow from `Branch: main`
- Environment: e.g. `production` (or `staging`, `qa`, or `dev`)
- Docker tag: e.g. `2641bebaf22ad96be543789693e015922e4514c41`

### Deploy a specific tag to an environment - Terraform via Makefile

This allows you to update the environment to use a previously-built Docker image

Note: Using the [Deploy App to Environment](https://github.com/DFE-Digital/teaching-vacancies/actions?query=workflow%3A%22Deploy+App+to+Environment%22)  workflow as outlined above is recommended in preference to this more manual approach below.

```bash
make passcode=<passcode> dev tag=47fd1475376bbfa16a773693133569b794408995 terraform-app-apply
```
performs these steps:

- Uses Terraform to apply any changes (including providing the tag of the Docker image) to the `dev` environment

Requirements:
- [terraform CLI](https://www.terraform.io/downloads.html) of at least version `0.15.5`
- Log in to GitHub Packages (with `docker login ghcr.io -u USERNAME` - use PAT token as passoword)
- Log in to GOV.UK PaaS (with `cf login --sso`). You will need a [Passcode](https://login.london.cloud.service.gov.uk/passcode)


## Replace PostgresDB

- Occasionally, we need to destroy and replace the postgres database. For instance, the database in `qa` is corrupt or not functioning as designed, we could use the makefile target - `terraform-app-database-replace` , which allows the database in a particular environment to destroyed and recreated.
```bash
`cf login --sso` - target appropriate space i.e. `review`
make review ci terraform-app-database-replace pr_id=3982 tag=main CONFIRM_REPLACE=yes
```
There is also a corresponding GitHub Action workflow - .github/workflows/recreate-qa-database.yml. Once the database has created, data would need to be seeded separately.


## Remove review app

### Remove review app - GitHub Actions

In usual circumstances, the review apps lifecycle will be handled via GitHub Actions:
- destruction via the [destroy.yml](.github/workflows/destroy.yml) workflow on PR close

### Remove review app - Terraform via Makefile

We can use the Makefile to destroy a review app, by passing a `CONFIRM_DESTROY=true` plus changing the action to `review-destroy`:
```
make passcode=MyPasscode pr=3134 CONFIRM_DESTROY=true review review-destroy
```

Requirements:
- [terraform CLI](https://www.terraform.io/downloads.html) of at least version `0.15.5`
- Log in to Docker Hub (with `docker login ghcr.io -u USERNAME` - use PAT token as passoword)
- Log in to GOV.UK PaaS (with `cf login --sso`). You will need a [Passcode](https://login.london.cloud.service.gov.uk/passcode)

### Remove review app - CloudFoundry CLI

Log in to Gov.UK PaaS:
```
cf login --sso
```

Switch to the teaching-vacancies-review space:
```
cf target -s teaching-vacancies-review
```

List, then delete, apps and routes
```
cf apps
cf delete -r teaching-vacancies-review-pr-3134
cf delete -r teaching-vacancies-worker-review-pr-3134
```

List, then delete, services
```
cf services
cf delete-service teaching-vacancies-postgres-review-pr-3134
cf delete-service teaching-vacancies-redis-review-pr-3134
cf delete-service teaching-vacancies-logging-review-pr-3134
```

Note: removing apps and services outside of Terraform will require removing the review terraform state file
```
aws-vault exec Deployments -- aws s3 rm s3://530003481352-terraform-state/review/review-pr-3134.tfstate
```
