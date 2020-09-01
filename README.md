# Teacher Vacancy Service (TVS)

* [Algolia Indexing](#algolia-indexing)
* [API Documentation](https://docs.teaching-vacancies.service.gov.uk) (External link)
* [API Keys](#api-keys)
* [Dependencies](#dependencies)
* [GovUK PaaS](/documentation/govuk-paas.md)
* [Front end development](#front-end-development)
* [Importing data](#importing-data)
* [Logging](/documentation/logging.md)
* [Misc](#misc)
* [Running the tests](#running-the-tests)
* [Secrets](#secrets)
* [Setup](#setup) (Start here!)
* [Troubleshooting](#troubleshooting)
* [User accounts](#user-accounts)

## User accounts

Before you can log in to the application locally, you will need to create a __DfE Sign-In__ account, be invited to a school, and be approved to join Teaching Vacancies. Once for the DfE Sign-In *production* environment, and once for DfE Sign-In *test* (staging) environment. Talk to the team to get these set up.

---

## Secrets

We currently use Keybase to manage our secrets. You will need to create an account, and be added to the team teachingjobs_dev as a writer. Then you will be able to clone and push to the secrets repo.

![Keybase Git](/documentation/images/keybase.png)

For details on specific API keys, see [API Keys](#api-keys).

---

## Algolia indexing

We use [Algolia's](https://algolia.com) search-as-a-service offering to provide an advanced search experience for our jobseekers.

To log in to the Algolia dashboard, you will need access to the teachingjobs@digital.education.gov.uk shared user, as the team size is limited by our payment tier.


### Environment Variables

```bash
ALGOLIA_APP_ID=<Get from API Keys on Algolia Dashboard>
ALGOLIA_SEARCH_API_KEY=<Get from API Keys on Algolia Dashboard>
ALGOLIA_WRITE_API_KEY=<Get from API Keys on Algolia Dashboard>
```

Use keys for one of the existing development sandboxes, or make new ones, if you are working locally.

### Quickstart

```ruby
  # To manually load an index with live records for the first time:
  Vacancy.reindex!
  # This now only loads records that are scoped `.live`

  # To update a live index with newly published records using minimal operations:
  Vacancy.update_index!

  # To remove records that expired yesterday:
  Vacancy.remove_vacancies_that_expired_yesterday!

  # To remove all expired vacancies.
  Vacancy.index.delete_objects(Vacancy.expired.map(&:id))
  # You should generally avoid doing this as it will create a large number of unnecessary operations
  # once these are being filtered out of the regular indexing operations.
```

Existing records will be updated so long as they continue to meet the [:listed?](app/models/vacancy.rb#280) conditions.

### Timed jobs

There are two timed jobs that run in sidekiq cron:

#### `UpdateAlgoliaIndex`

This runs every five minutes and add vacancies with matured `publish_on` times to the index.

#### `RemoveVacanciesThatExpiredYesterday`

This runs at 03:00 every day and does exactly what the name says it does. Daily removal is not a problem because expired vacancies that have not yet been removed will be filtered out by the search client and do not show to jobseekers.

### Development

When developing with [Algolia](https://algolia.com) you will find that *non-production environments will not start if
you try to use the Algolia production app*. There are multiple Algolia `Development` apps available and you are free to
make more if you need them. Details and api keys for the existing ones are available on the Algolia dashboard. You can
also make as many more free-tier apps as you like for testing, dev, etc.

If you do make new free-tier Algolia apps please make sure you include your name and/or ticket/PR numbers in the name so
we can keep track of these and clear them out occasionally.

Let your colleagues know if you take over an existing development app to be sure you don't accidentally step on anyone's
toes.

![Algolia ](/documentation/images/algolia.png)

#### Note on Free-Tier Algolia Apps

Community Apps, which are free, do not have team functionality. This means that you will not be able to access the dashboard
for apps that other people have created and they will not be able to access the dashboard for yours. If you need to
share an app dashboard between multiple users create it using the `teachingjobs` account.

This **only applies** to the `dev` (1RWSKBURHA - 'TVS DEV PAAS') and `staging` (CFWW19M6GM - 'TVS STAGING PAAS') shared
apps and any community apps you want to create for your own use/development work. It also does not affect your ability to
use apps for which you have the API keys. It **only** stops you from viewing the dashboard for **community apps** you
did not create.

### Indexing live records

We originally started by indexing all records. It became apparent that this had unnecessary cost implications, so the
codebase was refactored to index only live (or `listed`) records. The [Algolia](https://algoliac.om) Rails plugin is
now set so it automatically updates existing live records if they change.

NOTE: The default `#reindex!` method, added by the Algolia gem, has been overridden so it only indexes Vacancies records
that fall under the scope `#live`. This is to ensure that expired and unpublished records do not get accidentally added.

---

## Running the tests

### Ruby

This uses a standard `rspec` and `rubocop` stack. To run these locally:

```bash
bin/rake
# or
bundle exec rspec
```

### JavaScript

```bash
npm test
```

### Javascript

The full test suite including linting can be run as parallel tasks using the command:

```bash
yarn test
```

#### Unit tests

Tests are written using [Jest](https://jestjs.io/) and be run using:

```bash
yarn run js:test
```

To generate a coverage report of unit tests you can run:

```bash
yarn run js:test:coverage
```

#### Linting

Linting of Javascript files uses [ESLint](https://eslint.org/) and the ruleset is extended using [Airbnb rules](https://www.npmjs.com/package/eslint-config-airbnb) which are widely acknowledged as a comprehensive ruleset for modern Javascript. To run Javascript linting:

```bash
yarn run js:lint
```

### SASS

#### Linting

Linting of SASS files uses [Stylelint](https://stylelint.io/) default ruleset and can be run using:

```bash
yarn run sass:lint
```

---

## Troubleshooting

* I see Page Not Found when I log in and try to create a job listing.

Try [importing the school data](#importing-school-data) if you have not already. When your sign in account was created, it was assigned to a school via a URN, and you may not have a school in your database with the same URN.

---

## Setup

Welcome! :tada: :fireworks:

As you are on-boarded, please make a note of any issues you come across, and update the [documentation](https://docs.google.com/document/d/1qWU4qZ-17Y_ULlwD-rAM4rznaD6iNozV80kqO5ZRc0s), to improve the process for the next person.

First, clone the project with SSH:

```bash
git clone git@github.com:DFE-Digital/teacher-vacancy-service.git
```

If you are on a new device, remember to [generate a new SSH key](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

### Dependencies

#### Ruby version

```bash
$ ruby --version

ruby 2.7.1
```

The source of truth for the Ruby version is the [Gemfile](/Gemfile#L3).

You can use a tool like [asdf](https://asdf-vm.com/#/) to manage your versions of multiple languages.

#### NodeJS

Minimum version required:

```bash
$ node -v

node (>=) 8.0.0
```

The source of truth for the NodeJS version is [package.json](/package.json).

*** N.B NPM comes by default with nodeJS but [Yarn](https://classic.yarnpkg.com/en/) is the favoured package manager and should be used so the correct lock file is maintained when new packages are added or removed. ***

To install Yarn (as global dependency)

```bash
npm install yarn -g
```

#### Services

Make sure you have the following services configured and running on your development background:

* [PostgreSQL](#postgresql-setup) (database)

* [Redis](https://redis.io/topics/quickstart). Run the Redis server outside the project folder to avoid creating files in it.

* Sidekiq (performs cron jobs)

```bash
bundle exec sidekiq -C config/sidekiq.yml
```

#### Test and development dependency

 * [PhantomJS](https://phantomjs.org)

#### PostgreSQL Setup

If you are on a Mac, you most likely have PostgreSQL installed already.

With PostgreSQL installed and running, add a new user to [PostgreSQL](https://postgresql.org). Feel free to use any other method you are familiar with for adding postgres users. This is only an example. [Here](https://github.com/DFE-Digital/teacher-vacancy-service/wiki/PostgreSQL-Quickstart) is another.

```bash
createuser --interactive --pwprompt
```

For running local development and test environments, you can safely grant the user superuser access when asked.  **DO
NOT** do this for production environments.

#### AWS credentials

When onboarded, you will be provided with an AWS admin user. You can use it to access the AWS console at:
https://teaching-vacancies.signin.aws.amazon.com/console.

For programmatic access, including application deployment using terraform, create an API key for yourself in the AWS IAM section.
Then use the [aws cli](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) to configure the access key locally.

#### Environment Variables

Environment variables (eg: feature flags) are stored in `terraform/workspace-variables/<env>_app_env.yml` files
and secrets (eg: API keys) are stored in AWS SSM Parameter store in `/tvs/<env>/app/*` and `/tvs/<env>/infra/*`.

Run the following command to fetch the dev variables and output to a shell environment file:

```
make -s dev print-env > .env
```

You need [AWS credentials](#aws-credentials) to read and write from SSM.

We recommend using something like [`direnv`](/documentation/direnv.md) to load environment variables scoped into the folder.

Add your the details of your personal Algolia app (which you created earlier by following [this documentation](#development)) in the relevant space in your `.env`.

Set up the HTTPS certificates following the [HTTPS README](https://github.com/DFE-Digital/teacher-vacancy-service/blob/master/config/localhost/https/README.md). You will find them in the folder 'localhost-certificates' in the [secrets](#secrets).

#### Install libraries

Install the dependency libraries:

```bash
bundle # for Ruby gem dependencies
yarn install --check-files # for JavaScript packages
```

Then create and populate your database:

```bash
bundle exec rake db:create db:environment:set db:schema:load
```

#### Importing data

##### Importing location polygons data

Run these rake tasks to populate your database with LocationPolygons (which are used in some cases to search by location).

```ruby
rake data:location_polygons:import_cities
rake data:location_polygons:import_counties
rake data:location_polygons:import_london_boroughs
rake data:location_polygons:import_regions
```

##### Importing school data

Populate your environment with real school data. This is taken from
[GIAS](https://get-information-schools.service.gov.uk/). It might take a while, so make a cup of tea while you wait.

```bash
rake data:schools:import
```

##### Importing school group data

You can also populate your environment with real school group (trust) data. This is also taken from
[GIAS](https://get-information-schools.service.gov.uk/).

```bash
rake data:school_groups:import
```

Finally, [run your tests](#running-the-tests). If everything passes:

#### Run the server

To run the server outside docker:

```bash
rails s -b 'ssl://localhost:3000?key=config/localhost/https/local.key&cert=config/localhost/https/local.crt'
```

or

```bash
yarn run server
```

Look at that, you’re up and running! Visit https://localhost:3000/ and you’re ready to go.

##### Front end development

As the app is a Rails application, a tool called Webpacker is used for compiling frontend assets. Webpacker is a wrapper around [Webpack](https://webpack.js.org/), the popular asset pipeline tool for bundling assets. The Webpack dev server can be started in its own terminal tab using:

```bash
yarn run dev
```

This will re-bundle assets when files are saved for faster development.

---

## Misc

### Getting production-like data for local development

You can use conduit to create a dump of production data. See [this section](https://github.com/DFE-Digital/teacher-vacancy-service/blob/master/documentation/govuk-paas.md#backuprestore-govuk-paas-postgres-service-database) of the GovUK PaaS docs. Then you can load this into your local database:

```bash
psql tvs_development < backup.sql
```

### Integration between Jira and Github

The integration allows to see the status of development from within the jira issue. You can see the
status of branches, commits and pull requests as well as navigate to them to show the detail in Github.

To enable this, the following formatting must be used:
- Branch: Prefix with the issue id. Ex: `TEVA-1155-test-jira-github-integration`
- Commit: Prefix with the issue id between square bracket. Ex: `[TEVA-1155] Update Readme`
- Pull request: Prefix with the issue id between square bracket. If the branch was prefixed correctly,
this should be automatically added for you. Ex: `[TEVA-1155] Document Jira-Github integration`

The branch, commit or pull request will then appear in the `Development` side panel within the issue.

---

---

## API Keys

### ALGOLIA_WRITE_API_KEY
This key is used to index vacancies in Algolia.
In order to manage API keys:
1. Log in to Algolia using teachingjobs@digital.education.gov.uk
1. Go to the API Keys tab on the sidebar
1. Filter by API Key
1. Create new API key
1. Update ALGOLIA_WRITE_API_KEY in `set-*-govuk-paas-env.sh`
1. Rolling restart the application
1. Delete the old API key

### cloudwatch_slack_hook_url
Terraform variable containing encrypted URL to the Slack webhook. cloudwatch_ops_genie_api_key is not actually used but is commonly set to the same value as cloudwatch_slack_hook_url.
They need to be in an encrypted and base64 encoded format. There currently isn't a way to do this with Terraform, so to work around this:

1. Set `cloudwatch_slack_hook_url` and `cloudwatch_ops_genie_api_key` as their clear text values and apply, making sure to strip the protocol off `cloudwatch_slack_hook_url`.
1. Go to the Lambda function settings within the AWS Console.
1. Under 'Environment Variables', expand 'Encryption configuration' and select 'Enable helpers for encryption in transit'.
1. Select the 'tvs2-\<env\>-cloudwatch-lambda' key.
1. Select 'Encrypt' on both the `opsGenieApiKey` and `slackHookUrl` (or if editing, the one that's changed).
1. Click 'Save'.
1. Reload the page, and copy both of the (now encrypted) values, and replace `cloudwatch_slack_hook_url` and `cloudwatch_ops_genie_api_key` in your terraform variables file.
1. Run a terraform plan to ensure everything has been done correctly (You should not have any changes required for the lambda resource).

### SECRET_KEY_BASE
The secret_key_base is used as the input secret to the application's key generator, which in turn is used to create all MessageVerifiers/MessageEncryptors, including the ones that sign and encrypt cookies.
In order to generate a new secret key:
1. Run the `rails secret` task from the repo, it will generate a new secret key
1. You need to generate a different key per environment
1. Update `SECRET_KEY_BASE` in `set-*-govuk-paas-env.sh`

### ROLLBAR_ACCESS_TOKEN
Used to report server-side errors to Rollbar.
1. Navigate to: Setting > Project access tokens
1. Edit the token you want to revoke
1. Select `Yes, disable this token` and click `Save
1. Click `Create a new access token`
1. Select `post_server_item` and click Save
1. Update `ROLLBAR_ACCESS_TOKEN` in `set-*-govuk-paas-env.sh`

### ROLLBAR_CLIENT_ERRORS_ACCESS_TOKEN
Used to report client-side errors to Rollbar.
1. Access https://rollbar.com/
1. Navigate to: Setting > Project access tokens > Create a new access token
1. Select `post_client_item` and click Save
1. Update `ROLLBAR_ACCESSROLLBAR_CLIENT_ERRORS_ACCESS_TOKEN_TOKEN` in `set-*-govuk-paas-env.sh`

### DFE_SIGN_IN_PASSWORD and DFE_SIGN_IN_SECRET
* DFE_SIGN_IN_PASSWORD is used to encrypt JWT tokens to authorise a user with DFE sign-in.
* DFE_SIGN_IN_SECRET is OAuth2 client secret. It is only know to the application and the authorising server.

In order to update the password you need to have access to the DSI Manage console, it is specific to the environment (test, preprod, prod). This is the URL for test: https://test-manage.signin.education.gov.uk

__Once you are inside:__
1. Follow the `Service configuration` link
1. Regenerate the `Client secret` (`DFE_SIGN_IN_SECRET` env varialbe) and `API secret` (`DFE_SIGN_IN_PASSWORD` env variable)
1. Update `DFE_SIGN_IN_SECRET` and `DFE_SIGN_IN_PASSWORD` in the relevant `set-*-govuk-paas-env.sh` script file

### Google API Keys
There are several different API keys in use in different environments. There are keys for Google Maps, as well as service accounts for Google Analytics, BigQuery and Google Drive.
- `GOOGLE_MAPS_API_KEY` is used for Google Maps
- `GOOGLE_API_JSON_KEY` is used for analytics, indexing and drive
- `BIG_QUERY_API_JSON_KEY` is used for writing tables into BigQuery
- `CLOUD_STORAGE_API_JSON_KEY` is not used (as far as I can tell)

__NOTE: Keys with `JSON` in the name are `JSON` objects, not simple strings. They will need to be normalized in to `JSON` strings to be used in ENV variables.__

1. Go to the [Google Cloud Console API credentials section](https://console.cloud.google.com/apis/credentials?authuser=1&project=teacher-vacancy-service)
1. Always use your own login if it has sufficient permissions.
    * If it does not, request them on [#digital-tools-support](https://ukgovernmentdfe.slack.com/archives/CMS9V0JQL)
    * Please only use teachingjobs@digital.education.gov.uk as a last resort.

#### For a string-based API key follow this workflow:
1. Click 'CREATE CREDENTIALS' in the toolbar at the top of the page
1. Choose 'API key'
1. Click 'RESTRICT KEY' in the modal that appears
1. In 'Name' give the key a clear, descriptive name including environment details where applicable
1. Under 'Application Restrictions' select 'HTTP referres (web sites)'
1. Click 'ADD AN ITEM' under 'Website restrictions' and put in desired URL pattern.
1. Under 'API restrictions' choose 'Restrict key'
1. Select the API and access level for the key
1. Create one key per API and enviroment and use the minimum necessary permission(s) for that key
1. Click 'Save'
1. Copy your new key from the table and update it in the relevant `set-*-govuk-paas-env.sh` script files in the `teachinjobs_secrets` repo.
1. Do a rolling restart on the updated environment for the application
1. Check that everything works as expected
1. Delete the old API key from the Credentials table in the Google Cloud console
1. Notify anyone who needs to know that the key has been changed

#### For a `JSON` API keys follow this workflow:

##### To change a key on an existing service account (most common scenario):
1. You are now back on the dashboard. Find your new service account and click on it.
1. Click 'ADD KEY'
1. Pick 'Create new key'
1. Choose 'JSON' and click CREATE
1. The new key will be automatically downloaded. Once you have it, you can click 'CLOSE' on the modal
1. If you are on a mac, the easiest way to get the key into an `ENV` friendly format is using the `jq` tool. In a terminal:
    ```bash
    brew install jq
    cd <key download directory>
    jq -c . teacher-vacancy-service-<some UID>.json | pbcopy
    ```
1. Copy the full body of the new key as a json string (not necessary if you used `...| pbcopy` in the `jq` example, above)
1. Paste the full string of the new key into the relevant `set-*-govuk-paas-env.sh` script files in the `teachinjobs_secrets` repo. Make sure you paste it __between__ single quotes:
    ```bash
    cf7 set-env "$app_name" BIG_QUERY_API_JSON_KEY '{"type":"service_account","project_id":"teacher-vacancy-service","private_key_id":"0fe9069d...'
    ...
    ```
1. Do a rolling restart on the updated environment for the application
1. Check that everything works as expected
1. Delete the old key from the 'Keys' section in the Service Account window
1. Notify anyone who needs to know that the key has been changed

##### To create a new service account (usually not necessary):
1. Click 'CREATE CREDENTIALS' in the toolbar at the top of the page
1. Choose 'Service Account'
1. In 'Service account name' give the account a clear, descriptive name including environment details where applicable
1. Add a concise description of what the service account is for and what enviroments it is to be used in in 'Service account description'.
1. Click 'Create'
1. Add at least one role to restict the service account to a service. Use the minimum necessary permission(s) for the role.
1. Click 'Continue'
1. So far, our service account have not required user or group access, so you can skip the next step (click 'DONE'). This may change in the future.


### ORDNANCE_SURVEY_API_KEY
Used for geocoding.
The key cannot be revoked through the portal. Contact Ordnance survey support.

To create a new key:
1. Connect to https://developer.ordnancesurvey.co.uk/
1. Navigate to My Keys > Add a new key
1. Enter key name, select `OS Names API` and click `Save Key`
1. Copy the key to `set-*-govuk-paas-env.sh` and update ORDNANCE_SURVEY_API_KEY

### SKYLIGHT_AUTHENTICATION
Used by the app to report performance data to [Skylight](https://www.skylight.io/).
Managed by digital-tools.

### NOTIFY_KEY
Used to integrate with the GovUK Notify API.
1. Access https://www.notifications.service.gov.uk/
1. Navigate to API integration > API keys
1. Click `Revoke` on the old key
1. Click Create an API key
1. Add a specific name, select the type of key and click `Continue`
1. Copy the key to `set-*-govuk-paas-env.sh` and update NOTIFY_KEY
