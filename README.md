# Teacher Vacancy Service (TVS)

* [Algolia Indexing](#algolia-indexing)
* [API Documentation](https://docs.teaching-vacancies.service.gov.uk) (External link)
* [API Keys](#api-keys)
* [Dependencies](#dependencies)
* [Importing school data](#importing-school-data)
* [Misc](#misc)
* [Running the tests](#running-the-tests)
* [Troubleshooting](#troubleshooting)
* [User accounts](#user-accounts)

## User accounts 

Before you can log in to the application locally you will need a __DfE Sign-in__ and an __invitation to join Teaching
Vacancies__. Talk to the team to get these set up.

---

## Importing school data

Populate your environment with real school data. This is taken from
[GIAS](https://get-information-schools.service.gov.uk/)

```bash
rake data:schools:import
```
---

## Algolia indexing

We use [Algolia's](https://algolia.com) search-as-a-service offering to provide an advanced search experience for our
jobseekers. 

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
```

---

## Troubleshooting

_I see Page Not Found when I log in and try to create a job listing_

Try importing the school data if you have not already. When your sign in account was created, it was assigned to a
school via a URN, and you may not have a school in your database with the same URN.

---

## Dependencies

### Baseline

```bash
Ruby 2.6.6
```

### Services

Make sure you have the following services configured and running on your development background:

 * [Postgresql](https://postgresql.org)
 * [Redis](https://redis.io)

### Test and development dependencies

 * [PhantomJS](https://phantomjs.org)

### Installation and setup

Once you have Postgresql running add a new user:

```bash
createuser --interactive --pwprompt
```

For running local development and test environments, you can safely grant the user superuser access when asked.  **DO
NOT** do this for production environments.

Feel free to use any other method you are familiar with for adding postgres users. This is only an example.

Next, copy `dotenv.sample` to `.env`, edit it and change:

```bash
DATABASE_URL=postgres://<user>:<password>@localhost/<desired-database-name>
```

Now, install your gem dependencies, then create and populate your database:

```bash
bundle
bundle exec rake db:create db:environment:set db:schema:load
```

Finally, run your tests:

```bash
bundle exec rake
```

If everything passes, you're ready to get to work.

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
Used to integrate with the Notify API.
1. Access https://www.notifications.service.gov.uk/
1. Navigate to API integration > API keys
1. Click `Revoke` on the old key
1. Click Create an API key
1. Add a specific name, select the type of key and click `Continue`
1. Copy the key to `set-*-govuk-paas-env.sh` and update NOTIFY_KEY

---

## Misc

### RSpec formatters - Fuubar

Fuubar is a fast-failing progress bar formatter for RSpec. I've added the gem, but know from experience it isn't to
everyone's taste. If you want to use it, either start RSpec with the formatter switch:

```bash
bundle exec rspec --format Fuubar
```

or add it to your global `~/.rspec`:

```bash
--format Fuubar
```
