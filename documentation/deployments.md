# Deploy, update, and remove environments

## Build and deploy

### Build and deploy to review - GitHub Actions

This builds a Docker image from a feature branch, and then uses Terraform to create a complete environment in which to test it.

- Push to a feature branch.
- Create a Pull Request.
- attach a `deploy` label

The GitHub actions workflow [review.yml](/.github/workflows/review.yml) performs the steps below, if a `deploy` label is attached to the pull request. If not, the `build` and `deploy` jobs will not run:

- Builds a Docker image from code in the feature branch
- Tags the Docker image with the tags:
    - branch name (e.g. [TEVA-1797-update-school-type-summary](https://hub.docker.com/layers/dfedigital/teaching-vacancies/TEVA-1797-update-school-type-summary/images/sha256-dc01451b1486e40a3fb1a32ca577c65ece1a28a2ff27eefbd2455202c93caa71?context=explore)). Review apps often go through several iterations, so it's worth the creation of an image in order to speed up building from cache on subsequent pushes to the branch.
    - a composite tag containing the PR number and a unique timestamp (e.g. [review-pr-2664-80dd5f417a0faabfbe3f1a4bf8570eefec07139a-20210118172840](https://hub.docker.com/layers/dfedigital/teaching-vacancies/review-pr-2664-80dd5f417a0faabfbe3f1a4bf8570eefec07139a-20210118172840/images/sha256-dc01451b1486e40a3fb1a32ca577c65ece1a28a2ff27eefbd2455202c93caa71?context=explore)). This is useful for identifying the image.
- Logs in to GitHub's container registry as the service account `twd-tv-ci`
- Pushes the image to GitHub's container registry
- Calls the [deploy_app.yml](/.github/workflows/deploy_app.yml) workflow to use Terraform to update the `web` and `worker` apps to use the new Docker image, and apply any changes to the review environment
- Appends a comment to the Pull Request with the URL of the review app.
- Sends a Slack notification to the `#twd_tv_dev` channel:
> Review app for [https://github.com/DFE-Digital/teaching-vacancies/pull/2664/](https://github.com/DFE-Digital/teaching-vacancies/pull/2664/) deployed to [https://teaching-vacancies-review-pr-2664.london.cloudapps.digital](https://teaching-vacancies-review-pr-2664.london.cloudapps.digital) - success

### Build and deploy to dev - GitHub Actions

This builds and deploys a Docker image from code in the `dev` branch.

- Push to the [dev branch](https://github.com/DFE-Digital/teaching-vacancies/tree/dev).

The GitHub actions workflow [deploy_branch.yml](/.github/workflows/deploy_branch.yml) performs these steps:

- Builds a Docker image from code in the `dev` branch
- Tags the Docker image with the tag
- Logs in to GitHub's container registry as the service account `twd-tv-ci`
- Pushes the image to GitHub packages
- Calls the [deploy_app.yml](/.github/workflows/deploy_app.yml) workflow to use Terraform to update the `web` and `worker` apps to use the new Docker image, and apply any changes to the `dev` environment
- Sends a Slack notification to the `#twd_tv_dev` channel

### Build and deploy to staging and production - GitHub Actions

When a PR is approved and merged into `master` branch, the GitHub actions workflow [deploy.yml](/.github/workflows/deploy) performs these steps:

- Builds and tags a Docker image from code in the `master` branch
- Tags the Docker image with the commit SHA as the tag
- Logs in to Github's container registry as the service account `twd-tv-ci`
- Pushes the image to GitHub packages
- Calls the [deploy_app.yml](/.github/workflows/deploy_app.yml) workflow to use Terraform to update the `web` and `worker` apps to use the new Docker image, and apply any changes to the `staging` environment
- Runs a smoke test against the `staging` environment
- Calls the [deploy_app.yml](/.github/workflows/deploy_app.yml) workflow to use Terraform to update the `web` and `worker` apps to use the new Docker image, and apply any changes to the `production` environment
- Sends a Slack notification to the `#twd_tv_dev` channel

### Merge and concurrency deployment management
When there are multiple merges, this could lead to race conditions. To mitigate this, the `turnstyle` action prevents two or more instances of the same workflow from running concurrently.

Furthermore, to help with workflow code reuse, we trigger a separate deployment workflow via the [workflow_dispatch](https://docs.github.com/en/actions/reference/events-that-trigger-workflows#workflow_dispatch) action. We must pass the `ref` (branch) or pull request `ref` to locate the workflow.

To block the calling workflow until the triggered workflow is completed, we use `action-wait-for-check`. This checks and waits on a `sha` (commit) instead of `ref` (branch), which is a moving target.

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
- [terraform CLI](https://www.terraform.io/downloads.html) of at least version `0.15.5`
- Write access to Docker Hub `dfedigital/teaching-vacancies` repository. Ask in #digital-tools-support should you require it.
- Log in to Container registry (with `docker login ghcr.io -u USERNAME` - use PAT token as passoword)
- Log in to GOV.UK PaaS (with `cf login --sso`). You will need a [Passcode](https://login.london.cloud.service.gov.uk/passcode)

## Deploy a pre-built image

### Default tag

If no docker image tag is specified, the makefile defaults to using the `master` tag - as specified in the makfile's `terraform-app-init:` target

### Refresh an environment with updated Parameter Store secrets

The [refresh.yml](/.github/workflows/refresh.yml) workflow:
- is triggered on demand
- determines the current Docker image tag in use
- downloads secrets from the [AWS SSM Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table)
- uses Terraform to refresh the environment variables with the values from the Parameter Store

Go to the [Refresh environment](https://github.com/DFE-Digital/teaching-vacancies/actions?query=workflow%3A%22Refresh+environment%22) workflow:
Click "Run workflow", and choose:
- Use workflow from `Branch: master`
- Environment: e.g. `production` (or `staging`, `qa`, or `dev`)

### Deploy a specific tag to an environment - GitHub Actions

If you need to deploy a particular image to an environment, including in a rollback situation, this is possible with the [deploy_app.yml](/.github/workflows/deploy_app.yml) workflow.

You will need to know the tag of the Docker image you wish to use. Go to the [Github packages](https://github.com/DFE-Digital/teaching-vacancies/pkgs/container/teaching-vacancies)

E.g. [image tag 2641bebaf22ad96be543789693e015922e4514c4](https://hub.docker.com/layers/dfedigital/teaching-vacancies/2641bebaf22ad96be543789693e015922e4514c4/images/sha256-804c11e347b156a65c4ffe504e11e97917550d3ea11fed4e1697fdfc3725f3f7?context=explore)
is built from [commit 2641bebaf22ad96be543789693e015922e4514c4](https://github.com/DFE-Digital/teaching-vacancies/commit/2641bebaf22ad96be543789693e015922e4514c4)

Go to the [Deploy App to Environment](https://github.com/DFE-Digital/teaching-vacancies/actions?query=workflow%3A%22Deploy+App+to+Environment%22) workflow.
Click "Run workflow", and choose:
- Use workflow from `Branch: master`
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

## Remove review appxxxx

### Remove review app - GitHub Actions

In usual circumstances, the review apps lifecycle will be handled via GitHub Actions
- creation via the [review.yml](.github/workflows/review.yml) workflow on PR open or update
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
