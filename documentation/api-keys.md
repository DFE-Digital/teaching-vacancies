## API Keys

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
1. Update `SECRET_KEY_BASE` in [AWS Systems Manager Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table) `/teaching-vacancies/<env>/app/secrets` files

### DFE_SIGN_IN_PASSWORD and DFE_SIGN_IN_SECRET
* DFE_SIGN_IN_PASSWORD is used to encrypt JWT tokens to authorise a user with DFE sign-in.
* DFE_SIGN_IN_SECRET is OAuth2 client secret. It is only know to the application and the authorising server.

In order to update the password you need to have access to the DSI Manage console, it is specific to the environment (test, preprod, prod). This is the URL for test: https://test-manage.signin.education.gov.uk

__Once you are inside:__
1. Follow the `Service configuration` link
1. Regenerate the `Client secret` (`DFE_SIGN_IN_SECRET` env variable) and `API secret` (`DFE_SIGN_IN_PASSWORD` env variable)
1. Update `DFE_SIGN_IN_SECRET` and `DFE_SIGN_IN_PASSWORD` in [AWS Systems Manager Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table) `/teaching-vacancies/<env>/app/secrets` files

### Google API Keys
There are several different API keys in use in different environments. There are keys for Google Maps, as well as service accounts for Google Analytics, BigQuery and Google Drive.
- `GOOGLE_LOCATION_SEARCH_API_KEY` is used for both the Google Places API and the Google Geocoding API
- `GOOGLE_MAPS_API_KEY` is used for Google Maps
- `GOOGLE_API_JSON_KEY` is used for analytics, indexing and drive
- `BIG_QUERY_API_JSON_KEY` is used for writing tables into BigQuery

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
1. Under 'Application Restrictions' select 'HTTP referrers (web sites)'
1. Click 'ADD AN ITEM' under 'Website restrictions' and put in desired URL pattern.
1. Under 'API restrictions' choose 'Restrict key'
1. Select the API and access level for the key
1. Create one key per API and environment and use the minimum necessary permission(s) for that key
1. Click 'Save'
1. Copy your new key from the table and update it in [AWS Systems Manager Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table) `/teaching-vacancies/<env>/app/secrets` files
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
1. Paste the full string of the new key in [AWS Systems Manager Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table) `/teaching-vacancies/<env>/app/BIG_QUERY_API_JSON_KEY` or `/teaching-vacancies/<env>/app/GOOGLE_API_JSON_KEY` files
1. Do a rolling restart on the updated environment for the application
1. Check that everything works as expected
1. Delete the old key from the 'Keys' section in the Service Account window
1. Notify anyone who needs to know that the key has been changed

##### To create a new service account (usually not necessary):
1. Click 'CREATE CREDENTIALS' in the toolbar at the top of the page
1. Choose 'Service Account'
1. In 'Service account name' give the account a clear, descriptive name including environment details where applicable
1. Add a concise description of what the service account is for and what environments it is to be used in 'Service account description'.
1. Click 'Create'
1. Add at least one role to restrict the service account to a service. Use the minimum necessary permission(s) for the role.
1. Click 'Continue'
1. So far, our service account have not required user or group access, so you can skip the next step (click 'DONE'). This may change in the future.


### ORDNANCE_SURVEY_API_KEY
Used for geocoding.
The key cannot be revoked through the portal. Contact Ordnance survey support.

To create a new key:
1. Connect to https://developer.ordnancesurvey.co.uk/
1. Navigate to My Keys > Add a new key
1. Enter key name, select `OS Names API` and click `Save Key`
1. Update `ORDNANCE_SURVEY_API_KEY` in [AWS Systems Manager Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table) `/teaching-vacancies/<env>/app/secrets` files

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
1. Update `NOTIFY_KEY` in [AWS Systems Manager Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table) `/teaching-vacancies/<env>/app/secrets` files
