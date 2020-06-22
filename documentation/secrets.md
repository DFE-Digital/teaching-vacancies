# Application secrets

The application requires configuration to run. Most of the values are stored in the application github repository but some of them are secrets which can't be exposed in a public repository.
This documentation describes the usage of each secret, how to generate it and how to revoke it. This is critical inforamtion in case of a leak.

## ALGOLIA_WRITE_API_KEY
This key is used to index vacancies in Algolia.
In order to manage API keys:
1. Log in to Algolia using teachingjobs@digital.education.gov.uk
1. Go to the API Keys tab on the sidebar
1. Filter by API Key
1. Create new API key
1. Update ALGOLIA_WRITE_API_KEY in `set-*-govuk-paas-env.sh`
1. Rolling restart the application
1. Delete the old API key

## cloudwatch_slack_hook_url
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

## SECRET_KEY_BASE
The secret_key_base is used as the input secret to the application's key generator, which in turn is used to create all MessageVerifiers/MessageEncryptors, including the ones that sign and encrypt cookies.
In order to generate a new secret key:
1. Run the `rails secret` task from the repo, it will generate a new secret key
1. You need to generate a different key per environment
1. Update `SECRET_KEY_BASE` in `set-*-govuk-paas-env.sh`

## ROLLBAR_ACCESS_TOKEN
Used to report server-side errors to Rollbar.
1. Navigate to: Setting > Project access tokens
1. Edit the token you want to revoke
1. Select `Yes, disable this token` and click `Save
1. Click `Create a new access token`
1. Select `post_server_item` and click Save
1. Update `ROLLBAR_ACCESS_TOKEN` in `set-*-govuk-paas-env.sh`
## ROLLBAR_CLIENT_ERRORS_ACCESS_TOKEN
Used to report client-side errors to Rollbar.
1. Access https://rollbar.com/
1. Navigate to: Setting > Project access tokens > Create a new access token
1. Select `post_client_item` and click Save
1. Update `ROLLBAR_ACCESSROLLBAR_CLIENT_ERRORS_ACCESS_TOKEN_TOKEN` in `set-*-govuk-paas-env.sh`
## DFE_SIGN_IN_PASSWORD and DFE_SIGN_IN_SECRET
* DFE_SIGN_IN_PASSWORD is used to encrypt JWT tokens to authorise a user with DFE sign-in.
* DFE_SIGN_IN_SECRET is OAuth2 client secret. It is only know to the application and the authorising server.

In order to update the password you need to have access to the DSI Manage console, it is specific to the environment (test, preprod, prod). This is the URL for test: https://test-manage.signin.education.gov.uk

Once you are inside:
1. Follow the `Service configuration` link
1. Regenerate the `Client secret` (`DFE_SIGN_IN_SECRET` env varialbe) and `API secret` (`DFE_SIGN_IN_PASSWORD` env variable)
1. Update `DFE_SIGN_IN_SECRET` and `DFE_SIGN_IN_PASSWORD` in the relevant `set-*-govuk-paas-env.sh` script file

## Google API Keys
There are several different API keys in use in different environments.
Log in to console.cloud.google.com using teachingjobs@digital.education.gov.uk to manage the different keys.

1. Go to Explore and enable APIs in the Getting started card
1. Go to the Credentials tab in the sidebar
1. Create new API keys/service account keys
1. Update the API keys in the relevant `set-*-govuk-paas-env.sh` script files
1. Rolling restart the application
1. Delete the old API key

## ORDNANCE_SURVEY_API_KEY
Used for geocoding.
The key cannot be revoked through the portal. Contact Ordnance survey support.

To create a new key:
1. Connect to https://developer.ordnancesurvey.co.uk/
1. Navigate to My Keys > Add a new key
1. Enter key name, select `OS Names API` and click `Save Key`
1. Copy the key to `set-*-govuk-paas-env.sh` and update ORDNANCE_SURVEY_API_KEY

## SKYLIGHT_AUTHENTICATION
Used by the app to report performance data to [Skylight](https://www.skylight.io/).
Managed by digital-tools.

## NOTIFY_KEY
Used to integrat with the Notify API.
1. Access https://www.notifications.service.gov.uk/
1. Navigate to API integration > API keys
1. Click `Revoke` on the old key
1. Click Create an API key
1. Add a specific name, select the type of key and click `Continue`
1. Copy the key to `set-*-govuk-paas-env.sh` and update NOTIFY_KEY
