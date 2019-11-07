# GOV.UK PaaS

## Get GOV.UK PaaS account
Contact your organisation manager to get an account in `teacher-services` space.

## Intall Cloud Foundry CLI v7 on Mac
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

## Login
```bash
cf7 login -a $CF_API_ENDPOINT -u $CF_USERNAME -p $CF_PASSWORD -o $CF_ORG -s $CF_SPACE
```

# Check space users
```bash
cf space-users $CF_ORG $CF_SPACE
```

# Check organization users
```bash
cf org-users $CF_ORG -a
```

# Set/unset role
Get user id: 107451381990550193519

```bash
cf set-space-role USER_ID $CF_ORG $CF_SPACE SpaceDeveloper
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
You should see `postgres`, `redis`, `elasticsearch` and `papertrail` configured for `production` and `staging` environments

## Check app health and status

### Production
```bash
cf7 app teaching-vacancies-production
```

### Staging
```bash
cf7 app teaching-vacancies-staging
```

## Check environment

### Production
```bash
cf7 env teaching-vacancies-production
```

### Staging
```bash
cf7 env teaching-vacancies-staging
```

## SSH into app

### Production
```bash
cf7 ssh teaching-vacancies-production
```

### Staging
```bash
cf7 ssh teaching-vacancies-staging
```

## Access Rails console

### Production
```bash
cf7 ssh teaching-vacancies-production -t -c "/tmp/lifecycle/launcher /home/vcap/app 'rails console' ''"
```

### Staging
```bash
cf7 ssh teaching-vacancies-staging -t -c "/tmp/lifecycle/launcher /home/vcap/app 'rails console' ''"
```

## Run task

### Production
```bash
cf7 run-task teaching-vacancies-production "rails task:name"
```

### Staging
```bash
cf7 run-task teaching-vacancies-staging "rails task:name"
```

## Deploy to staging
```bash
bin/deploy-staging
```

## CI/CD with GitHub Actions
Tests run every time is pushed on a branch.

When a PR is approved and merged into `master` branch an automatic deploy is triggered to `production` environment.

## Set up production

### Create services
All the services are specified in the `manifest.yml` file and are automatically bounded on deploy

#### Postgres
```bash
cf7 create-service postgres medium-ha-11 teaching-vacancies-postgres-production -c '{"enable_extensions": ["pgcrypto", "fuzzystrmatch", "plpgsql"]}'
```

#### Redis
```bash
cf7 create-service redis small-ha-4.x teaching-vacancies-redis-production
```

#### Elasticsearch
```bash
cf7 create-service elasticsearch small-ha-6.x teaching-vacancies-elasticsearch-production
```

#### Papertrail
Get log destination from Papertrail
```bash
cf7 create-user-provided-service teaching-vacancies-papertrail-production -l syslog-tls://logsX.papertrailapp.com:XXXXX
```

### Set environment variables
For all the environment variables defined in `.env.example` set them up with:
```bash
cf7 set-env teaching-vacancies-production ENV_VAR_NAME env_var_value
```
When you are done setting up environment variables remember to restart the app:
```bash
cf7 restart teaching-vacancies-production
```

## Set up staging

### Create services
All the services are specified in the `manifest-staging.yml` file and are automatically bounded on deploy

#### Postgres
```bash
cf7 create-service postgres tiny-unencrypted-11 teaching-vacancies-postgres-staging -c '{"enable_extensions": ["pgcrypto", "fuzzystrmatch", "plpgsql"]}'
```

#### Redis
```bash
cf7 create-service redis tiny-4.x teaching-vacancies-redis-staging
```

#### Elasticsearch
```bash
cf7 create-service elasticsearch tiny-6.x teaching-vacancies-elasticsearch-staging
```

#### Papertrail
Get log destination from Papertrail
```bash
cf7 create-user-provided-service teaching-vacancies-papertrail-staging -l syslog-tls://logsX.papertrailapp.com:XXXXX
```

### Set environment variables
For all the environment variables defined in `.env.example` set them up with:
```bash
cf7 set-env teaching-vacancies-staging ENV_VAR_NAME env_var_value
```
When you are done setting up environment variables remember to restart the app:
```bash
cf7 restart teaching-vacancies-staging
```

## Backup/Restore GOV.UK PaaS Postgres service database
Install Conduit plugin
```bash
cf7 install-plugin conduit
```

### Backup

#### Production
```bash
cf7 conduit teaching-vacancies-postgres-production -- pg_dump -f backup.sql
```

#### Staging
```bash
cf7 conduit teaching-vacancies-postgres-staging -- pg_dump -f backup.sql
```

### Restore

#### Production
```bash
cf7 conduit teaching-vacancies-postgres-production -- psql < backup.sql
```

#### Staging
```bash
cf7 conduit teaching-vacancies-postgres-staging -- psql < backup.sql
```
