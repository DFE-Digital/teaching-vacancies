# DSI Contingency Fallback Playbook

## Background

We rely on DfE Sign In to provide our authentication and authorisation.

This fallback method relies on the data we have on users from our nightly job UpdateDfeSignInUsersJob: specifically, the email addresses and the organisation URNs.

It replaces the DSI sign in method with one whereby the user is prompted to enter their email address, and clicks a unique login link. This login link works only once and expires after a configurable time.

## How to use

Here are the steps to follow to use our contingency fallback sign-in method. 

First, decide whether to switch on the fallback authentication. This call should be made by the Product Owner if they are available.
   - An alternative to this fallback sign in method could be replacing DSI with a notice to users. To do this, we would reinstate the environment variable and code which was deleted in commit [`🔥 Remove FEATURE_SIGN_IN_ALERT flag`](https://github.com/DFE-Digital/teacher-vacancy-service/pull/1647/commits/0458874730fed3fdb25053e217be50bc4677e705).

### Switching it on

Switch on the fallback authentication by setting the environment variable `AUTHENTICATION_FALLBACK` to `true`.
   
### Switching it off

Switch off the fallback authentication by setting the environment variable `AUTHENTICATION_FALLBACK` to `false`.

Save space in the database by deleting all `EmergencyLoginKey`s:

```ruby
rake db:emergencyloginkeys:clear
```

If you don't do this, the (currently) monthly job `ClearEmergencyLoginKeys` will pick it up later.

## Optional extras

End all sessions (without warning users beforehand):

```
rake db:sessions:clear
```

This does not end any sessions cached by DSI.

### Configuration

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
Session.where('created_at > ?', Time.zone.today).size # => 13519

# Here is some pre-fallback production data for comparison.
```
