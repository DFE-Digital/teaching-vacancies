# Hosting

Teaching Vacancies is hosted on [GOV.UK PaaS](https://docs.cloud.service.gov.uk/).

## Environments

| Environment | URL                                                                                                    | Code branch | CI/CD workflow      | Gov.UK PaaS space             |
| ----------- | ------------------------------------------------------------------------------------------------------ | ----------- | ------------------- | ----------------------------- |
| Production  | [https://teaching-vacancies.service.gov.uk](https://teaching-vacancies.service.gov.uk)                 | `main`    | [deploy.yml](../.github/workflows/deploy.yml)        | teaching-vacancies-production |
| Staging     | [https://staging.teaching-vacancies.service.gov.uk](https://staging.teaching-vacancies.service.gov.uk) | `main`    | [deploy.yml](../.github/workflows/deploy.yml)        | teaching-vacancies-staging    |
| Dev         | [https://dev.teaching-vacancies.service.gov.uk](https://dev.teaching-vacancies.service.gov.uk)         | `dev`       | [deploy_branch.yml](../.github/workflows/deploy_branch.yml) | teaching-vacancies-dev        |
| QA          | [https://qa.teaching-vacancies.service.gov.uk](https://qa.teaching-vacancies.service.gov.uk)           | `qa`        | [deploy_branch.yml](../.github/workflows/deploy_branch.yml) | teaching-vacancies-dev        |
| Prototype   | [https://teaching-vacancies-prototype.london.cloudapps.digital](https://teaching-vacancies-prototype.london.cloudapps.digital/) |   |    | teaching-vacancies-prototype |

Plus all the ephemeral review apps that are created when a PR is created on GitHub, and destroyed when the PR is merged. These have URLs which contain the Pull Request number, like [https://teaching-vacancies-review-pr-2667.london.cloudapps.digital](https://teaching-vacancies-review-pr-2667.london.cloudapps.digital)

The Dev and QA environments have [integration with DSI](./dsi-integration.md). They are "user-deployable", in that developers can [deploy](./deployments.md) via:
- [pushing code to the `dev` or `qa` branches](./deployments.md#build-and-deploy-to-dev---github-actions)
- [Makefile commands](./deployments.md#build-and-deploy-to-an-environment---makefile)

The Staging environment is a pre-production environment, to identify issues with code before it's promoted to Production.
On merging a Pull Request, the same code is deployed first to Staging, and after a successful smoke test, to Production.
## Gov.UK PaaS organisation and permission model

An [organisation](https://docs.cloud.service.gov.uk/orgs_spaces_users.html#organisations)
> represents a group of users, applications and environments. Each org shares the same resource, quota and custom domain.
Teaching Vacancies is in the [dfe organisation](https://docs.cloud.service.gov.uk/orgs_spaces_users.html#organisations)

An org is divided into one or more [spaces](https://docs.cloud.service.gov.uk/orgs_spaces_users.html#spaces). A space is a shared location for developing, deploying and running apps and backing services.

Teaching Vacancies has 6 spaces:
- teaching-vacancies-dev
- teaching-vacancies-monitoring
- teaching-vacancies-production
- teaching-vacancies-prototype
- teaching-vacancies-review
- teaching-vacancies-staging

During [onboarding](./onboarding.md) you will have been granted access to selected spaces and [roles](https://docs.cloud.service.gov.uk/orgs_spaces_users.html#users-and-user-roles):

By default, you will have the `SpaceDeveloper` role in the:
- `Sandbox` space
- `teaching-vacancies-dev` space

Senior developers, Tech Leads, and DevOps have the `SpaceManager` role in all required spaces.

- Space developer - can deploy, run and manage apps, and create and bind services. This is the default role for any user who is not assigned a manager role.
- Space manager - grants user roles within a space and can change space properties using the command line. A space manager cannot deploy, run, or manage apps or services.
- Space auditor - can view apps, users and resources used within a space using the command line, but cannot edit them. This role is useful for viewing app data without modifying it.
- Billing manager - create and manage billing account and payment information

## Logging on and changing role

- [Enable Google SSO for Gov.UK PaaS](https://docs.cloud.service.gov.uk/get_started.html#use-single-sign-on)
- Log in to GOV.UK PaaS (with `cf login --sso`). You will need a [Passcode](https://login.london.cloud.service.gov.uk/passcode)
- Once you've selected a space, you should see your user ID (between `API version` and `org: dfe`)
- Add your user ID and name to [this SSO Confluence page](https://dfedigital.atlassian.net/wiki/spaces/BaT/pages/1935048705/Single+sign-on+SSO) so that it's easier to identify you.
- A colleague with the `Space manager` role can [set or unset the Space developer role](#setunset-spacedeveloper-role) as required.

## Install Cloud Foundry CLI on Mac

```bash
brew install cloudfoundry/tap/cf-cli@7
```

## Login

```bash
CF_API_ENDPOINT=https://api.london.cloud.service.gov.uk
CF_ORG=dfe
```

Set `CF_SPACE` to environment(space) you want to deal with, e.g. `teaching-vacancies-dev`
```bash
CF_SPACE=teaching-vacancies-dev
```

For convenience and for security reasons we recommend to use SSO to login:

```bash
cf login --sso -a $CF_API_ENDPOINT -o $CF_ORG -s $CF_SPACE
```

If you need to login with a service account to access production environment:

```bash
cf login -a $CF_API_ENDPOINT -u $CF_USERNAME_PROD -p $CF_PASSWORD_PROD -o $CF_ORG -s $CF_SPACE
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

- If you have the `SpaceManager` role, note that the safest option is to remove yourself from the Space Developer role when not using it

## Check running apps

```bash
cf apps
```

There should be 2 apps (more in the case of review apps space):

- webapp: it has a route to serve requests from users
- worker: it subscribe to redis to run asynchronous jobs

## Check running services

```bash
cf services
```

## Check app health and status

```bash
cf app <app_name>
```

## Check environment variables

```bash
cf env <app_name>
```

## Set environment variable

Environment variables are stored in AWS SSM Parameter store and in the repository. Terraform sets them automatically when it deploys the applications to GOV.UK PaaS.

Should you wish to override an individual variable directly:

```bash
cf set-env <app_name> ENV_VAR_NAME env_var_value
cf restart <app_name> --strategy rolling
```

Remember to restart the app, using `--strategy rolling` if you wish to avoid downtime.
In the case of changing environment variables used only by the app, `restart` is sufficient and `restage` is unnecessary:

```bash
cf restart <app_name> --strategy rolling
```

## SSH into app

```bash
cf ssh <app_name>
```

## Access Rails console

```bash
cf ssh <app_name>
cd /app
/usr/local/bin/bundle exec rails console
```

```Makefile
make <env> console e.g. make qa console
```
## Run task

```bash
cf run-task <app_name> -c "rails task:name"
```
## CI/CD with GitHub Actions

Tests run every time is pushed on a branch.

## Maintenance windows for GOV.UK PaaS Postgres and Redis services

From [Redis maintenance times](https://docs.cloud.service.gov.uk/deploying_services/redis/#redis-maintenance-times)

> Every Redis service has a maintenance window of Sunday 11pm to Monday 1:30am UTC every week.

From [PostgreSQL maintenance times](https://docs.cloud.service.gov.uk/deploying_services/postgresql/#postgresql-maintenance-times):

> Each PostgreSQL service you create will have a randomly-assigned weekly 30 minute maintenance window, during which there may be brief downtime. Select a high availability (HA) plan to minimise this downtime. Minor version upgrades (for example from 9.4.1 to 9.4.2) are applied during this maintenance window.
>
> Window start times will vary from 22:00 to 06:00 UTC.

Discussed with Product Owner

- Redis - leave as Sunday 23:00 to Monday 01:30
- Postgres staging - set as Tuesday 23:16 to Tuesday 23:46
- Postgres production - set as Wednesday 23:16 to Wednesday 23:46

With the intention being:
- maintenance overnight on Sunday, Tuesday, Wednesday mean any issues can be remediated on working days (Monday, Wednesday, Thursday)
- this avoid Tuesday as sprint ceremonies day, and Friday when fewer people are working
- staging happens a day before production, so that we can detect failures in the lower environment first

We set these with the CloudFoundry CLI commands, opting for the safer option of applying this configuration change during a maintenance window:
```
cf update-service teaching-vacancies-postgres-staging -p small-11 -c '{"apply_at_maintenance_window": true, "preferred_maintenance_window": "tue:23:16-tue:23:46"}'
cf update-service teaching-vacancies-postgres-production -p medium-ha-11 -c '{"apply_at_maintenance_window": true, "preferred_maintenance_window": "wed:23:16-wed:23:46"}'
```

## Backup/Restore GOV.UK PaaS Postgres service database

Install Conduit plugin

```bash
cf install-plugin conduit
```

### Backup

```bash
cf conduit $CF_POSTGRES_SERVICE_ORIGIN -- pg_dump -x --no-owner -c -f backup.sql
```

### Restore

```bash
cf conduit $CF_POSTGRES_SERVICE_TARGET -- psql < backup.sql
```

## Set up a new environment
- Create file `terraform/workspace-variables/<env>.tfvars.json`
- Create file `terraform/workspace-variables/<env>_app_env.yml`
- Create SSM parameters of type `SecureString`:
  - `/teaching-vacancies/<env>/app/BIG_QUERY_API_JSON_KEY`
  - `/teaching-vacancies/<env>/app/GOOGLE_API_JSON_KEY`
  - `/teaching-vacancies/<env>/app/secrets`
  - `/teaching-vacancies/<env>/infra/secrets`
- Add a target to the Makefile
```
.PHONY: <env>
<env>: ## <env>
		$(eval env=<env>)
		$(eval var_file=<env>)
```
- Run:
  ```shell
  make passcode=MyPasscode tag=47fd1475376bbfa16a773693133569b794408995 <env> terraform-app-apply
  ```
- If you want to have a deployment triggered by a push to a branch, add a trigger to [deploy_branch.yml](../.github/workflows/deploy_branch.yml)
```
on:
  push:
    branches:
      - dev
      - <env>
```
- Optionally, [refresh the database](database-backups.md) with a sanitised copy of the production data
