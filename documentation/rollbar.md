# Rollbar

We use [Rollbar](https://www.rollbar.com) to track errors occurring in the application.

## Internal Server Error pages

Our 500 page will include the Rollbar UUID of the error that was just raised. This is
helpful when users experience an error and contact support with a screenshot or a copy
of the message. To view an error on Rollbar given a UUID, sign in to Rollbar and visit
the following URL:

```
https://rollbar.com/occurrence/uuid/?uuid=[UUID goes here]
```
