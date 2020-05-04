# GOV.UK PaaS

## Get GOV.UK PaaS account
Contact your organisation manager to get an account in `dfe-teacher-services` organization and in the relevant spaces:

- teaching-vacancies-dev
- teaching-vacancies-staging
- teaching-vacancies-production

## Install Cloud Foundry CLI v7 on Mac
We use version 7 because it enables processes, that we use for Sidekiq

```bash
brew install cloudfoundry/tap/cf7-cli
```

## Set environment variables
We recommend something like `direnv` to load environment variables scoped into the folder

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

Change `$CF_SPACE` if you want to access different environments:

- teaching-vacancies-dev
- teaching-vacancies-staging
- teaching-vacancies-production

In the following guide replace `teaching-vacancies-dev` with the environment you are dealing with.

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
cf space-users $CF_ORG $CF_SPACE
```

## Check organization users
```bash
cf org-users $CF_ORG -a
```

## Set/unset SpaceDeveloper role
```bash
cf set-space-role USER_ID $CF_ORG $CF_SPACE SpaceDeveloper
cf unset-space-role USER_ID $CF_ORG $CF_SPACE SpaceDeveloper
```

## Check running apps
```bash
cf7 apps
```
You should see `teaching-vacancies-dev`

## Check running services
```bash
cf7 services
```
You should see `postgres`, `redis`, `elasticsearch` and `papertrail`.

## Check app health and status
```bash
cf7 app teaching-vacancies-dev
```

## Check environment variables
```bash
cf7 env teaching-vacancies-dev
```

## SSH into app
```bash
cf7 ssh teaching-vacancies-dev
```

## Access Rails console
```bash
cf7 ssh teaching-vacancies-dev -t -c "/tmp/lifecycle/launcher /home/vcap/app 'rails console' ''"
```

## Run task
```bash
cf7 run-task teaching-vacancies-dev "rails task:name"
```

## Deploy to dev
Set `$CF_SPACE` to `teaching-vacancies-dev` and login again.

```bash
cf7 push -f manifest-dev.yml
```

## Deploy to staging
Set `$CF_SPACE` to `teaching-vacancies-staging` and login again.

```bash
cf7 push -f manifest-staging.yml
```

## CI/CD with GitHub Actions
Tests run every time is pushed on a branch.

When a PR is approved and merged into `master` branch an automatic deploy is triggered to `production` environment.

## Set up environment

### Create services
All the services are specified in the `manifest.yml` file and are automatically bounded on deploy.

```
teaching-vacancies-dev -> manifest-dev.yml
teaching-vacancies-staging -> manifest-staging.yml
teaching-vacancies-production -> manifest.yml
```

#### Postgres
Dev and staging environments use `tiny-unencrypted-11`, production uses `medium-ha-11`

```bash
cf7 create-service postgres tiny-unencrypted-11 teaching-vacancies-postgres-dev -c '{"enable_extensions": ["pgcrypto", "fuzzystrmatch", "plpgsql"]}'
```

#### Redis
Dev and staging environments use `tiny-4.x`, production uses `small-ha-4.x`

```bash
cf7 create-service redis tiny-4.x teaching-vacancies-redis-dev
```

#### Elasticsearch
Dev and staging environments use `tiny-6.x`, production uses `small-ha-6.x`

```bash
cf7 create-service elasticsearch tiny-6.x teaching-vacancies-elasticsearch-dev
```

#### Papertrail
Get log destination from Papertrail
```bash
cf7 create-user-provided-service teaching-vacancies-papertrail-dev -l syslog-tls://logsX.papertrailapp.com:XXXXX
```

### Set environment variables
For all the environment variables defined in `.env.example` set them up with:
```bash
cf7 set-env teaching-vacancies-dev ENV_VAR_NAME env_var_value
```

You will be asked to stage the changes. Do so with:
```bash
cf7 stage teaching-vacancies-dev
```

Verify the changes:
```bash
cf7 env teaching-vacancies-dev
```

When you are done setting up environment variables, remember to restart the app, using `--strategy rolling` if you wish to avoid downtime:
```bash
cf7 restart teaching-vacancies-dev --strategy rolling
```

## Backup/Restore GOV.UK PaaS Postgres service database
Install Conduit plugin
```bash
cf7 install-plugin conduit
```

### Backup
```bash
cf7 conduit teaching-vacancies-postgres-dev -- pg_dump -f backup.sql
```

### Restore
```bash
cf7 conduit teaching-vacancies-postgres-dev -- psql < backup.sql
```
