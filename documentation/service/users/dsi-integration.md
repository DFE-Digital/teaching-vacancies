# Authentication

Hiring staff authenticate via the [DfE Sign-in](https://services.signin.education.gov.uk/) system. When [onboarded](/documentation/team/developer_onboarding.md) you are associated with more than one organisation.

Different environments talk to different DfE Sign-in environments:

- Local development -> Test DfE Sign-in
- Staging AKS -> Pre-production DfE Sign-in
- Production AKS -> Production DfE Sign-in
- QA AKS -> Test DfE Sign-in

Review apps use the magic link sent via email to authenticate.

## DfE Sign-in configuration

### Service configuration access

In order to manage the DfE Sign-In service configuration, you must be granted access via a request in [Service Now](https://dfe.service-now.com.mcas.ms/serviceportal?id=sc_cat_item&sys_id=0c00c1afdb6bc8109402e1aa4b961937&sysparm_category=2f6e34afdb6bc8109402e1aa4b9619aa).

### Service configuration URLs

- [Test](https://test-manage.signin.education.gov.uk/services/E348F7D4-93D9-4B43-9B78-C84D80C2F34C/service-configuration)
- [Pre-production](https://pp-manage.signin.education.gov.uk/services/EF3E84E7-950A-4CB2-B1B0-66417F3CD5CA/service-configuration)
- [Production](https://manage.signin.education.gov.uk/services/E348F7D4-93D9-4B43-9B78-C84D80C2F34C/service-configuration)

### Service configuration

Within the service configuration screen, you are able to:
- Regenerate the Client secret
- Add Redirect Urls
- Add Logout Redirect Urls
- Specify Response types (currently `code`)
- Specify Token endpoint authentication method (currently `none`)
- Regenerate the API secret

### Set environment variables

The following are set per-environment, e.g. [terraform/workspace-variables/dev_app_env.yml](../terraform/workspace-variables/dev_app_env.yml)

```
DFE_SIGN_IN_ISSUER: https://test-oidc.signin.education.gov.uk
DFE_SIGN_IN_REDIRECT_URL: https://dev.teaching-vacancies.service.gov.uk/auth/dfe/callback
DFE_SIGN_IN_URL: https://test-api.signin.education.gov.uk
```

Sensitive values are set per-environment in the [AWS Systems Manager Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table), e.g. `/teaching-vacancies/<env>/app/secrets`

```
DFE_SIGN_IN_IDENTIFIER=
DFE_SIGN_IN_PASSWORD=
DFE_SIGN_IN_SECRET=
```

## DSI Contingency Fallback Playbook

### Background

We rely on DfE Sign In (DSI) to provide our authentication and authorisation.

This is a contingency plan for when DSI has an outage. The fallback authentication method relies on the data we have on users from our nightly job UpdateDSIUsersInDbJob: specifically, the email addresses and the organisation URNs.

It replaces the DSI sign in method with one whereby the user is prompted to enter their email address, and clicks a unique login link. This login link works only once and expires after a configurable time.

### How to use

Here are the steps to follow to use our contingency fallback sign-in method.

First, decide whether to switch on the fallback authentication. This call should be made by the Product Owner/Manager if they are available.
   - An alternative to this fallback sign in method could be replacing DSI with a notice to users telling them that they can't access the service. To do this, we would reinstate the environment variable and code which was deleted in commit [🔥 Remove FEATURE_SIGN_IN_ALERT flag](https://github.com/DFE-Digital/teaching-vacancies/commit/bc12fb9808c955f86cd87e62648a76786516e2c3).

### Toggle Authentication Fallback

- Switch on the fallback authentication by setting the environment variable `AUTHENTICATION_FALLBACK` to `true`.
- Switch off the fallback authentication by setting the environment variable `AUTHENTICATION_FALLBACK` to `false`.

#### Toggling Authentication Fallback Using an automated deployment

Changing the environment variable within the `<env>_app_env.yml` follows the standard deployment procedure, and allows deployments to production to continue:
- create a feature branch
- edit the file [terraform/workspace-variables/production_app_env.yml](../terraform/workspace-variables/production_app_env.yml)
- set the environment variable `AUTHENTICATION_FALLBACK` to `true` or `false` as required
- create a Pull Request
- merge after approval

#### Toggling Authentication Fallback Using manual steps

The following method is included for completeness, but should be considered as a "panic mode" option only.
It requires `SpaceDeveloper` permission on the `s189-teacher-services-cloud-production` subscription, and only persists until the next [Automated Deployment to staging and production](/documentation/operations/deployment/deployments.md#build-and-deploy-to-staging-and-production---github-actions)

- Block all deployments to `production` by requesting in the Slack channel `#tv_devs`
- Log in in the [Azure Portal](https://portal.azure.com.mcas.ms/) and request access to the `s189-Contributor and Key Vault editor` role in the `s189-teacher-services-cloud-production` subscription.
- Once having the access granted by one of the managers, login into Azure from the console:
  ```bash
  az login --tenant 9c7d9dd3-840c-4b3f-818e-552865082e16
  ```
- Get the credentials for the production cluster:
  ```bash
  make production get-cluster-credentials CONFIRM_PRODUCTION=YES
  ```
- Get the current environment value:
  ```bash
  kubectl -n tv-production exec deployment/teaching-vacancies-production -- env | grep AUTHENTICATION_FALLBACK
  ```
- Get current environment variable value over one of the listed pods:


- Update the environment variable with the [set env](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#-em-env-em-) command
- Enable the fallback with:
  ```bash
  kubectl -n tv-production set env deployment/teaching-vacancies-production AUTHENTICATION_FALLBACK=true
  ```

- Wait for a bit until the pods get automatically restarted with the new value. Check that the value changed:
  ```bash
  kubectl -n tv-production exec deployment/teaching-vacancies-production -- env | grep AUTHENTICATION_FALLBACK
  ```

- When not needed anymore disable the fallback with:
  ```bash
  kubectl  -n tv-production set env  deployment/teaching-vacancies-production AUTHENTICATION_FALLBACK=false
  ```

### Optional extras

End all sessions (without warning users beforehand):

```
rails db:sessions:clear
```

This does not end any sessions cached by DSI (assuming DSI is live).

### Configuration

Adjust the length of time before an EmergencyLoginKey expires with `EMERGENCY_LOGIN_KEY_DURATION` in [Publishers::LoginKeysController](app/controllers/publishers/sign_in/email/sessions_controller.rb)

Adjust the default session duration with `TIMEOUT_PERIOD` in [Publishers::BaseController](app/controllers/publishers/base_controller.rb).

Adjust all text involved in the fallback authentication under `temp_login` in [config/locales/en.yml](config/locales/en.yml).

### Monitoring

We won't audit the fallback sign-ins as we do for DSI sign-ins, but we will still see sign-ins in our logs: `"Hiring staff signed in via fallback authentication: #{oid}"`

To see the number of sessions created since you switched on the fallback authentication, ssh into the rails console, then:

```ruby
# Create a Session class to access the database table 'sessions'
class Session < ActiveRecord::Base
end

# Example query: how many sessions were created today?
Session.where('created_at > ?', Date.current).size # => 13519
```
