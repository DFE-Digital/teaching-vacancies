# Deploy, update, and remove environments

## Build and deploy

### Build and deploy - GitHub Actions

The deployments to all environments share the same and simplified workflow. The deployment to review app (via Pull Request), qa, staging and production go through the CI/CD pipeline.

Once the PR has been merged to main or a `deploy` tag applied to Review app, the GitHub actions workflow [build_and_deploy.yml](/.github/workflows/build_and_deploy.yml) performs these steps:

- Builds and tags a Docker image from code in the `main` (staging, prod and qa) or `review app` branch
- Tags the Docker image with the commit SHA as the tag
- Logs in to Github's container registry as the service account `twd-tv-ci`
- Pushes the image to GitHub packages, after it has been scanned by `Snyk` for vulnerabilities.
    - See [this guide](/documentation/operations/infrastructure/docker.md#docker-image-scan) on how to fix vulnerability errors that may arise at this stage.
- Calls the [deploy_app.yml](/.github/actions/deploy/action.yml) action to use Terraform to update the `web` and `worker` apps to use the new Docker image, and apply any changes to the appropriate environment.
- Runs a smoke test against the deployed environment
- If deployment (push) is to the main branch, performs `Post Deployment`
- Sends a Slack notification to the `#twd_tv_dev` channel - success or failure.

### Build and deploy to review - GitHub Actions

Perform the following to trigger a deployment a review app

- Push to a feature branch.
- Create a Pull Request.
- attach a `deploy` label
- Docker image and tag used to deploy the `review app` is based on the review app's `branch` and `sha` e.g teva-1234:commit_sha

#### Review app databases and cache/queues
By default, review apps differ from the rest on environments on:
- PostgreSQL DB: uses a postgis docker container deployed to AKS, instead of real Azure database flexible servers
- Redis Cache and Queue: uses a redis docker container deployed to AKS, instead of real Azure Redis Cache servers.

These AKS containers are cheaper and much faster to deploy, what is convenient for our ephemereal Review Apps.

The Docker images used for the containers are set in the [Teacher Services Cloud repository](https://github.com.mcas.ms/DFE-Digital/teacher-services-cloud/blob/main/.ghcr_cache_images.yml).

To use the Azure database temporarily in a review app, you can change the following parameters to `true` in `terraform/workspace-variables/review.tfvars.json` on the branch (do not commit this hange to main, remove it before merging):

```json
"deploy_azure_backing_services": true,
"enable_postgres_ssl": true,
"add_database_name_suffix": true,
```
#### Review app deployment failures

Sometimes, a review apps seem to timeout with a message like:

> module.paas.module.web_application.kubernetes_deployment.main: Still creating... [9m50s elapsed]
>
> │ Error: Waiting for rollout to finish: 1 replicas wanted; 0 replicas Ready

This may mean that the Review App startup process was terminated with an exception.

To identify possible exceptions you can:

- Check the Sentry errors for `review` environment.

- Check the logs for the review app pod:
  - `kubectl -n tv-development get pods` To identify the review app pod we want to check.
  - `kubectl -n tv-development logs -f POD_NAME` To view logs.

     For example: `kubectl -n tv-development logs -f teaching-vacancies-review-pr-7546-c7476575b-gfbd4`

### Merge and concurrency deployment management
When there are multiple merges, this could lead to race conditions. To mitigate this, the `turnstyle` action prevents two or more instances of the same workflow from running concurrently.

Furthermore, to help with workflow code reuse, we trigger a separate deployment workflow via the [workflow_dispatch](https://docs.github.com/en/actions/reference/events-that-trigger-workflows#workflow_dispatch) action. We must pass the `ref` (branch) or pull request `ref` to locate the workflow.

To block the calling workflow until the triggered workflow is completed, we use `action-wait-for-check`. This checks and waits on a `sha` (commit) instead of `ref` (branch), which is a moving target.


### Refresh cached docker image: `ghcr.io/dfe-digital/teaching-vacancies:main`

Refresh the cached `ghcr.io/dfe-digital/teaching-vacancies:main` image on Github packages. In case the build workflow fails at the `Scan ghcr.io/dfe-digital/teaching-vacancies:main image` stage, it may be that a fix is available but our cache is stale; with the vulnerable dependency. In this case use the [rebuild_docker_cache_workflow](/.github/workflows/rebuild_docker_cache.yml) to refresh the cache with updated packages. The rebuild_docker_cache_workflow is scheduled on a weekly run (12 noon on Sundays) and can also be triggered manaully via workflow dispatch.


## Deploy a pre-built image

### Default tag

If no docker image tag is specified, the makefile defaults to using the `main` tag - as specified in the makfile's `terraform-app-init:` target

### Deploy a specific tag to an environment - GitHub Actions

If you need to deploy a particular image to an environment, including in a rollback situation, this is possible with the [deploy_app_via_workflow_dispatch.yml](/.github/workflows/deploy_app_via_workflow_dispatch.yml) workflow.

You will need to know the tag of the Docker image you wish to use. Go to the [Github packages](https://github.com/DFE-Digital/teaching-vacancies/pkgs/container/teaching-vacancies)

E.g. [image tag 2641bebaf22ad96be543789693e015922e4514c4](https://hub.docker.com/layers/dfedigital/teaching-vacancies/2641bebaf22ad96be543789693e015922e4514c4/images/sha256-804c11e347b156a65c4ffe504e11e97917550d3ea11fed4e1697fdfc3725f3f7?context=explore)
is built from [commit 2641bebaf22ad96be543789693e015922e4514c4](https://github.com/DFE-Digital/teaching-vacancies/commit/2641bebaf22ad96be543789693e015922e4514c4)

Go to the [Deploy App via workflow Dispatch](https://github.com/DFE-Digital/teaching-vacancies/actions/workflows/deploy_app_via_workflow_dispatch.yml) workflow.
Click "Run workflow", and choose:
- Use workflow from `Branch: main`
- Environment: e.g. `production` (or `staging`, `qa`)
- Docker tag: e.g. `2641bebaf22ad96be543789693e015922e4514c41`

## Remove review app

The review apps lifecycle will be handled via GitHub Actions:
- destruction via the [delete_review_app.yml](/.github/workflows/delete_review_app.yml) workflow on PR close

This workflow can be triggered manually, passing the PR number corresponding to the review app to remove.

### Deleting review apps manually

Sometimes, the [delete_review_app.yml](/.github/workflows/delete_review_app.yml) workflow errors as the review app
wasn't healthy/accesible and failed the initial "is this review app running?" check.

The kubernetes pods and other AKS resources (DB, Redis instances...) may still be running but orphaned once the PR is
closed and the deletion job fails.

In those cases, we will need to manually delete the review app by:
1. Deleting the review app kubernetes deployment through `kubectl`.
2. Deleting the review app Azure resources through the Azure Portal page.

#### Deleting the review app Kubernetes deployment
- Login in the azure tenant and get credentials for the AKS testing subscription.
- Identify the review app we want to delete, by listing the current deployments:
  ```bash
  kubectl -n tv-development get deployments
  ```
  In this example, we identify `teaching-vacancies-review-pr-6488` as the review app that needs to be removed.
  Delete each of the review app deployment resources with `kubectl`:
- Delete the web app deployment with `kubectl`:
  ```bash
   kubectl -n tv-development delete deployment teaching-vacancies-review-pr-6488
  ```
- Delete the worker:
  ```bash
   kubectl -n tv-development delete deployment teaching-vacancies-review-pr-6488-worker
  ```
- Delete the database:
  ```bash
   kubectl -n tv-development delete deployment teaching-vacancies-review-pr-6488-postgres
  ```
- Delete the Redis cache:
  ```bash
   kubectl -n tv-development delete deployment teaching-vacancies-review-pr-6488-redis-cache
  ```
- Dekete the Redis queue:
  ```bash
   kubectl -n tv-development delete deployment teaching-vacancies-review-pr-6488-redis-queue
  ```
