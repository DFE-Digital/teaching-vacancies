# GitHub Actions

## Secrets

> Secrets are environment variables that are encrypted and only exposed to selected actions. Anyone with collaborator access to this repository can use these secrets in a workflow.
>
> Secrets are not passed to workflows that are triggered by a pull request from a fork.

### Secret lifecycle

With sufficient privileges, these are available under [Settings/Secrets](https://github.com/DFE-Digital/teacher-vacancy-service/settings/secrets)

Secrets may be:
- Added
- Updated
- Removed

Secrets can not be decrypted/viewed through the web portal, but only through workflows

### Secret use grouped by workflow

#### ALGOLIA_APP_ID
- test.yml

#### ALGOLIA_SEARCH_API_KEY
- test.yml

#### ALGOLIA_WRITE_API_KEY
- test.yml

#### AWS_ACCESS_KEY_ID
- deploy_branch.yml
- deploy.yml
- destroy.yml
- review.yml
- sync_staging_db.yml

#### AWS_SECRET_ACCESS_KEY
- deploy_branch.yml
- deploy.yml
- destroy.yml
- review.yml
- sync_staging_db.yml

#### CF_API_ENDPOINT
- sync_staging_db.yml

#### CF_ORG
- sync_staging_db.yml

#### CF_PASSWORD
- deploy_branch.yml
- deploy.yml
- destroy.yml
- review.yml
- sync_staging_db.yml

#### CF_SPACE
- sync_staging_db.yml

#### CF_USERNAME
- deploy_branch.yml
- deploy.yml
- destroy.yml
- review.yml
- sync_staging_db.yml

#### DOCKER_PASSWORD
- deploy_branch.yml
- deploy.yml
- review.yml

#### DOCKER_USERNAME
- deploy_branch.yml
- deploy.yml
- review.yml

#### PERSONAL_TOKEN
- deploy.yml

#### RECAPTCHA_SECRET_KEY
-test.yml

#### RECAPTCHA_SITE_KEY
-test.yml

#### SLACK_WEBHOOK
- deploy_branch.yml
- deploy.yml
- destroy.yml
- review.yml
- smoke-test-manual.yml
- smoke-test.yml
- sync_staging_db.yml

#### SONAR_TOKEN
- test.yml
