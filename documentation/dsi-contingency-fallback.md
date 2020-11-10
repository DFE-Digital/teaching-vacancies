# DSI Contingency Fallback Playbook

## Background

We rely on DfE Sign In (DSI) to provide our authentication and authorisation.

This is a contingency plan for when DSI has an outage. The fallback authentication method relies on the data we have on users from our nightly job UpdateDsiUsersInDbJob: specifically, the email addresses and the organisation URNs.

It replaces the DSI sign in method with one whereby the user is prompted to enter their email address, and clicks a unique login link. This login link works only once and expires after a configurable time.

## How to use

Here are the steps to follow to use our contingency fallback sign-in method. 

First, decide whether to switch on the fallback authentication. This call should be made by the Product Owner/Manager if they are available.
   - An alternative to this fallback sign in method could be replacing DSI with a notice to users telling them that they can't access the service. To do this, we would reinstate the environment variable and code which was deleted in commit [`🔥 Remove FEATURE_SIGN_IN_ALERT flag`](https://github.com/DFE-Digital/teacher-vacancy-service/commit/bc12fb9808c955f86cd87e62648a76786516e2c3).

### Switching it on

Switch on the fallback authentication by setting the environment variable `AUTHENTICATION_FALLBACK` to `true`.
   
### Switching it off

Switch off the fallback authentication by setting the environment variable `AUTHENTICATION_FALLBACK` to `false`.

Save space in the database by deleting all `EmergencyLoginKey`s:

```ruby
rake db:emergencyloginkeys:clear
```

## Optional extras

End all sessions (without warning users beforehand):

```
rails db:sessions:clear
```

This does not end any sessions cached by DSI (assuming DSI is live).

### Configuration

Adjust the length of time before an EmergencyLoginKey expires with `EMERGENCY_LOGIN_KEY_DURATION` in [`HiringStaff::SignIn::Email::SessionsController`](app/controllers/hiring_staff/sign_in/email/sessions_controller.rb)

Adjust the default session duration with `TIMEOUT_PERIOD` in [`HiringStaff::BaseController`](app/controllers/hiring_staff/base_controller.rb).

Adjust all text involved in the fallback authentication under `temp_login` in [`config/locales/en.yml`](config/locales/en.yml).

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
