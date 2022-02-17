# Bot mitigation

## What
Currently there are several forms on the service that can be accessed and submitted by anybody. These are open to spam and exploitation by bots.

Google's recaptcha v3 was implemented on these forms in order to start obtaining recaptcha 'scores' which would help identify suspicious requests.

## Why
This version of the recaptcha does not obstruct the user (or bot) in any way and as a result we still receive some spam. Notably this results in bots creating job alert subscriptions.

We want to prevent this from happening, so intend to use the recaptcha scores to stop forms being submitted when the actor is identified as being 'suspicious'

## How
Google don't reveal much information on how recaptcha scores work, or what indeed is 'suspicious', however they do [suggest](https://developers.google.com/recaptcha/docs/v3#interpreting_the_score) that a threshold of 0.5 might be a good place to start.

For context, a threshold of 0.5 would have impacted just 1.7% of total form submissions.

When form submissions have a recaptcha score below this threshold, we will:
- invalidate the submission
- redirect the bot to an /invalid-request page
- provide an email link with the subject 'Invalid request - %{form name}'
- log the event to Sentry

This strategy should be monitored and revisited and iterated on to ensure we filter out bots as much as possible while impacting real users as infrequently as possible.
