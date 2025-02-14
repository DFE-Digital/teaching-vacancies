# Sentry

We use [Sentry](https://www.sentry.io) to track errors occurring in the application.

## Internal Server Error pages

Our 500 page will include the Sentry UUID of the error that was just raised. This is
helpful when users experience an error and contact support with a screenshot or a copy
of the message. To view an error on Sentry given a UUID, go to the issues view and use
the search bar to search for the UUID.
