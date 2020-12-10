# Events

## Context

We want to keep improving our service so that users have the best possible experience. To achieve
this, we need to have a broad idea of how users behave and what impact new features and changes
have on their actions. We also have a need to audit certain events for security and compliance
purposes.

We allow users to explicitly opt in to non-essential cookies and client-side analytics, and very
few do so, which limits the amount and significance of data we can gather through frontend
analytics tools. These tools also do not allow us to track events that occur outside of the
application frontend, and present with privacy and cross-site tracking concerns.

To solve this problem, we have implemented an event-based backend data platform. Events are
triggered within our application and shipped to our data warehouse (currently Google BigQuery).

## Events

At its most basic, an event has a type and a timestamp at which it occurred. Many events will also
include some sort of metadata, which can be specified in a key/value format:

```ruby
Event.new.trigger(:reticulated_splines, foo: "bar")
```

Events can be triggered at any point in the application, but if triggered as part of the Rails
request lifecycle (i.e. in a controller), we can include a richer set of metadata based on request,
response, current user, and session information. The `ApplicationController` includes a
`#request_event` method that can be used to easily trigger events in controllers:

```ruby
class FooController < ApplicationController
  def show
    request_event.trigger(:something_happened, foo: params["bar"])
  end
end
```

We trigger a `page_visited` event for every successful HTTP request (except PaaS healthchecks and
API calls), so every page view will result in at least one event, but may result in more if custom
events are triggered.

## Privacy

We create anonymised (hashed) versions of identifiable information, including a combination of a
user's IP address and user agent, internal user identifiers, and session ID, to be able to
aggregate events based on pertaining to one user (but not who that user is specifically). We also
collect raw user agent and IP address information for events that result from a user request,
which we will handle according to our privacy policy. 
