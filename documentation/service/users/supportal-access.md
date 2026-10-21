# Supportal access

"Supportal" is the support dashboard for DfE support staff (`SupportUser` accounts). It is also the
gate in front of internal tools such as Mission Control (`/solid_queue_jobs`), `/field_test` and
Publisher ATS API client management (`/support-users/publisher_ats_api_clients`).

Support users sign in through **DfE Sign In (DSI)** like publishers do, but when DSI is down and
`AUTHENTICATION_FALLBACK` is on, they must use a **different fallback entry point** from publishers.
Using the publisher fallback will never give you Supportal access.

## Entry points

| | DSI available | DSI down (`AUTHENTICATION_FALLBACK=true`) |
| --- | --- | --- |
| **Support user** | `/support-users/sign-in` -> DSI button -> `/auth/dfe` | `/support-users/sign-in` -> enter email -> emailed link to `/support-users/fallback_sessions/:id` |
| **Publisher** | `/publishers/sign-in` -> `/auth/dfe` | `/publishers/login_keys/new` -> emailed link -> choose organisation |

Code: `SupportUsers::SessionsController`, `SupportUsers::FallbackSessionsController`,
`Publishers::LoginKeysController`, `OmniauthCallbacksController#dfe`.

## When DSI is up

1. Go to `/support-users/sign-in` and choose to sign in with DSI.
2. After DSI authenticates you, `OmniauthCallbacksController#dfe` asks DSI for your roles
   (`Publishers::DfeSignIn::Authorisation#authorised_support_user?`). The support check runs
   **before** the publisher check, so anyone holding the support role in DSI lands in Supportal,
   whichever page they started from.
3. The `SupportUser` record is created on your first DSI sign-in (`find_or_create`).

## When DSI is down and the fallback is on

The fallback only works for people who **already exist as a `SupportUser`**. The sign-in page says as
much: "You will only be able to sign in if you have used the support dashboard before."

1. Go to `/support-users/sign-in`. With the fallback on, the DSI button is replaced by an email form.
2. Enter your support user email. If it matches a `SupportUser`, a sign-in link is emailed through
   GOV.UK Notify (`SupportUsers::AuthenticationFallbackMailer`).
   The page gives the same response whether or not the email matched, so a typo or an unknown
   address looks identical to success.
3. Open the link within **5 minutes**. It is a signed ID (`SupportUsers::FallbackSessionsController`),
   and signs you in and redirects to the dashboard.

### Keeping access during an outage

- Sign in to Supportal via DSI at least once **before** an outage, so your `SupportUser` exists.
  Anyone new during an outage cannot get in through the fallback.
- Use the support sign-in page, not the publisher one. The publisher flow
  (`/publishers/login_keys/new`, 10 minute `EmergencyLoginKey`) only creates a publisher session.
- The flag is read once at boot, so changing `AUTHENTICATION_FALLBACK` needs a redeploy or pod
  restart before `/support-users/sign-in` changes. How to toggle it:
  [DSI contingency fallback playbook](dsi-integration.md#dsi-contingency-fallback-playbook).
- If the web app is reachable but the email never arrives, check that the Solid Queue worker is
  running (the email is sent with `deliver_later`) and that Notify is up.

## Troubleshooting

| Symptom | Cause |
| --- | --- |
| Email never arrives | Email isn't a `SupportUser`, the job queue isn't running, or Notify is down |
| Link gives a 404 | Link older than 5 minutes, or altered or truncated |
| Sign-in page still shows the DSI button during an outage | The flag isn't set in the running pods yet |
| Fallback signs you in as a publisher | You used the publisher login key page |
| Fallback is off but you can't reach DSI | `/support-users/fallback_sessions` redirects back to sign-in; turn the flag on first |

## Related

- [DSI integration and fallback playbook](dsi-integration.md)
