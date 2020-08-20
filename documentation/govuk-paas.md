# GOV.UK PaaS

## Get GOV.UK PaaS account
You will need to get an account in `dfe-teacher-services` organization. An organisation manager will grant you access to the relevant spaces. This should be requested in the Slack channel #digital-tools-support.

## Install Cloud Foundry CLI v7 on Mac
We use version 7 because it enables processes that we use for Sidekiq and rolling deployments.

```bash
brew install cloudfoundry/tap/cf7-cli
```

## Set environment variables

See "Environment variables" in the README to fetch the required variables for each environment.

We recommend something like [`direnv`](/documentation/direnv.md) to load environment variables scoped into the folder

```bash
cp .env.example .env
```

Make sure you have the following environment variables set:

```
CF_API_ENDPOINT=https://api.london.cloud.service.gov.uk
CF_ORG=dfe-teacher-services
CF_SPACE=teaching-vacancies-dev
CF_USERNAME=xxx
CF_PASSWORD=xxx
```

Change `$CF_SPACE` to the environment(space) you want to deal with.

## Login
For convenience and for security reasons we recommend to use SSO to login:

```bash
cf7 login --sso -a $CF_API_ENDPOINT -o $CF_ORG -s $CF_SPACE
```

If you need to login with a service account:

```bash
cf7 login -a $CF_API_ENDPOINT -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE
```

## Check space users
```bash
cf7 space-users $CF_ORG $CF_SPACE
```

## Check organization users
```bash
cf7 org-users $CF_ORG -a
```

## Set/unset SpaceDeveloper role
```bash
cf7 set-space-role USER_ID $CF_ORG $CF_SPACE SpaceDeveloper
cf7 unset-space-role USER_ID $CF_ORG $CF_SPACE SpaceDeveloper
```

## Check running apps
```bash
cf7 apps
```

There should be 2 apps:
- webapp: it has a route to serve requests from users
- worker: it subscribe to redis to run asynchronous jobs

## Check running services
```bash
cf7 services
```

## Check app health and status
```bash
cf7 app <app_name>
```

## Check environment variables
```bash
cf7 env <app_name>
```

## Set environment variable

Environment variables are stored in AWS SSM Parameter store and in the repository. Terraform sets them automatically when it deploys the applications to paas.

Should you wish to override an individual variable directly:

```bash
cf7 set-env <app_name> ENV_VAR_NAME env_var_value
cf7 restart <app_name> --strategy rolling
```

Remember to restart the app, using `--strategy rolling` if you wish to avoid downtime.
In the case of changing environment variables used only by the app, `restart` is sufficient and `restage` is unnecessary:
```bash
cf7 restart <app_name> --strategy rolling
```

## SSH into app
```bash
cf7 ssh <app_name>
```

## Access Rails console
```bash
cf7 ssh <app_name>
cd /teacher-vacancy
/usr/local/bin/bundle exec rails console
```

## Run task
```bash
cf7 run-task <app_name> -c "rails task:name"
```

## Deploy to dev or staging via commandline
This builds and deploys a Docker image from local code.

```bash
passcode=<passcode> make <environment> deploy-local-image
```
performs these steps:

- Builds and tags a Docker image from local code
- Pushes the image to Docker Hub
- Runs terraform to deploy the docker image

You need:
- Write access to Docker Hub `dfedigital/teaching-vacancies` repository. Ask in #digital-tools-support should you require it.
- `SpaceDeveloper` role in the paas space you want to deploy to
- Log in to Docker Hub (with `docker login`) and GOV.UK PaaS in your terminal
- Obtain SSO passcode from https://login.london.cloud.service.gov.uk/passcode

```bash
make dev deploy-local-image # Deploy to dev
make staging deploy-local-image # Deploy to staging
```

## Deploy to dev or staging via a commit to GitHub
This builds and deploys a Docker image from code in `dev` or `staging` branches.

Push to the `dev` or `staging` branch.
The GitHub actions workflow [deploy_branch.yml](/.github/workflows/deploy_branch.yml) performs these steps:

- Builds and tags a Docker image from code in the GitHub branch
- Pushes the image to Docker Hub
- Deploys the Docker image to PaaS
- Sends a Slack notification to the `#twd_tv_dev` channel

## CI/CD with GitHub Actions
Tests run every time is pushed on a branch.

When a PR is approved and merged into `master` branch an automatic deploy is triggered to `production` environment.

## Backup/Restore GOV.UK PaaS Postgres service database
Install Conduit plugin
```bash
cf7 install-plugin conduit
```

### Backup
```bash
cf7 conduit $CF_POSTGRES_SERVICE_ORIGIN -- pg_dump -x --no-owner -c -f backup.sql
```

### Restore
```bash
cf7 conduit $CF_POSTGRES_SERVICE_TARGET -- psql < backup.sql
```

## Set up a new environment
- Create file `terraform/workspace-variables/<env>.tfvars`
- Create file `terraform/workspace-variables/<env>_app_env.yml`
- Create SSM parameters of type `SecureString`:
  - `/tvs/<env>/app/BIG_QUERY_API_JSON_KEY`
  - `/tvs/<env>/app/CLOUD_STORAGE_API_JSON_KEY`
  - `/tvs/<env>/app/GOOGLE_API_JSON_KEY`
  - `/tvs/<env>/app/secrets`
  - `/tvs/<env>/infra/secrets`
- Run:
  ```shell
  export TF_VAR_paas_sso_passcode=<passcode obtained from https://login.london.cloud.service.gov.uk/passcode>
  export TF_WORKSPACE=<env>
  export TF_VAR_paas_app_docker_image=dfedigital/teaching-vacancies:<tag>
  terraform init terraform/app
  terraform apply -var-file terraform/workspace-variables/<env>.tfvars terraform/app
  ```
