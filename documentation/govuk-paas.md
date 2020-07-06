# GOV.UK PaaS

## Get GOV.UK PaaS account
You will need to get an account in `dfe-teacher-services` organization. An organisation manager will grant you access to the relevant spaces. This should be requested in the Slack channel #digital-tools-support.

## Install Cloud Foundry CLI v7 on Mac
We use version 7 because it enables processes that we use for Sidekiq and rolling deployments.

```bash
brew install cloudfoundry/tap/cf7-cli
```

## Set environment variables
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

Set all the variables defined in `.env.example`. There are scripts to facilitate that in the Git repository on Keybase.

Update the script `set- <your environment> -govuk-paas-env.sh` with the correct variables, and then run it. For example:

```bash
./set-dev-govuk-paas-env.sh
```

Remember to restart the app, using `--strategy rolling` if you wish to avoid downtime. In the case of changing environment variables used only by the app, `restart` is sufficient and `restage` is unnecessary:
```bash
cf7 restart <app_name> --strategy rolling
```

You can also set an individual variable directly:

```bash
cf7 set-env <app_name> ENV_VAR_NAME env_var_value
cf7 restart <app_name> --strategy rolling
```

## SSH into app
```bash
cf7 ssh <app_name>
```

## Access Rails console
```bash
cf7 ssh <app_name> -t -c "/tmp/lifecycle/launcher /home/vcap/app 'rails console' ''"
```

**NOTE:** This didn't work as expected on the new docker containers.  If you get the following error: 

```bash
cf7 ssh <app_name> -t -c "/tmp/lifecycle/launcher /home/vcap/app 'rails console' ''"
Invalid metadata - unexpected end of JSON input%
```

use this workaround:

```bash
cf7 ssh <app_name>
cd /teacher-vacancy
/usr/local/bin/bundle exec rails console
```

## Run task
```bash
cf7 run-task <app_name> -c "rails task:name"
```

## Deploy to dev
Make sure you are logged in `teaching-vacancies-dev` space.

```bash
cf7 push -f paas/web/manifest-dev.yml
cf7 push -f paas/worker/manifest-dev.yml
```

## Deploy to staging
Make sure you are logged in `teaching-vacancies-staging` space.

```bash
cf7 push -f paas/web/manifest-staging.yml
cf7 push -f paas/worker/manifest-staging.yml
```

## CI/CD with GitHub Actions
Tests run every time is pushed on a branch.

When a PR is approved and merged into `master` branch an automatic deploy is triggered to `production` environment.

## Set up environment on GOV.UK PaaS

### Create services
All the services are specified in the `manifest.yml` file and are automatically bound on deploy.

```
teaching-vacancies-dev -> manifest-dev.yml
teaching-vacancies-staging -> manifest-staging.yml
teaching-vacancies-production -> manifest-production.yml
```
Make sure you are logged in the relevant space.

#### Postgres
- dev
  ```bash
  cf7 create-service postgres tiny-unencrypted-11 teaching-vacancies-postgres-dev -c '{"enable_extensions": ["pgcrypto", "fuzzystrmatch", "plpgsql"]}'
  ```
- staging
  ```bash
  cf7 create-service postgres tiny-unencrypted-11 teaching-vacancies-postgres-staging -c '{"enable_extensions": ["pgcrypto", "fuzzystrmatch", "plpgsql"]}'
  ```
- production
  ```bash
  cf7 create-service postgres medium-ha-11 teaching-vacancies-postgres-production -c '{"enable_extensions": ["pgcrypto", "fuzzystrmatch", "plpgsql"]}'
  ```

#### Redis
- dev
  ```bash
  cf7 create-service redis tiny-4.x teaching-vacancies-redis-dev
  ```
- staging
  ```bash
  cf7 create-service redis tiny-4.x teaching-vacancies-redis-staging
  ```
- production
  ```bash
  cf7 create-service redis small-ha-4.x teaching-vacancies-redis-production
  ```

#### Papertrail
Get log destination from Papertrail
```bash
cf7 create-user-provided-service teaching-vacancies-papertrail-(dev|staging|production) -l syslog-tls://logsX.papertrailapp.com:XXXXX
```

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
