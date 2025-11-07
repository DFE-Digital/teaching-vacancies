# Actioning user Support Requests

Support Requests are brought to us through the Microsoft Teams `OPS TV Support` channel.

The requests brought there are triaged by our Business Analysts (BAs), sometimes the BAs resolve the queries themselves and doesn't require our intervention.

If they require a developer intervention, they will ping us.


## If production access is required

It is usual for us to require a rails console access in the production environment to debug and/or action a user request.

To do so, developers need to obtain Production environment access through a PIM request for `s189 TV production PIM` group, and the proceed to obtain a rails console.

This process is described in the [hosting docs](/documentation/operations/infrastructure/hosting.md).

## Regular Support User Requests

### Unlink Jobseekers from their GovUK One Login account
If a jobseeker reset their GovUK One Login account, they will direct them to our service support with a request to unlink their GovUK One Login from our service.

#### What does this mean

Jobseekers in our DB are associated to a GovUK One Login account through the `govuk_one_login_id` field.

After they have got their GovUK One Login account reset, the jobseeker coming from One Login will match our DB user by email, but their One Login ID will be different.

In that situation they would not be able to sign-in in to their existing account in our service due to the One Login ID missmatch.

By unlinking their account from GovUK One Login, we wipe the existing ID and allow the incoming user with the matching email to be re-associated with their TV user.

This re-linking process happens automatically as long as there is no existing `govuk_one_login_id` value for the user.

#### How to action it

1. Obtain production access console.
2. Unlink the particular Jobseeker using the ad-hoc method for this process: `Jobseeker#unlink_from_govuk_one_login!`


### Delete Jobseeker data

Sometimes we get requests for deleting the user data completely from our system.

We have to obtain a production access console and check if the user has any Job Application associated to their account.

#### If the Jobseeker has no Job Applications

The developer can safely `destroy` the user (ensure to do a `destroy` call so triggers callbacks & associations deletions as needed).

#### If the Jobseeker has Job Applications

We shouldn't delete y these users information, as we may have legal requirements due to Job Applications or communications between them and the Publishers.

Run this by our BA/team to decide how to proceed and for them to respond to the request.

### Publishers reporting access issues to the service

Sometimes Publishers report seeing [this error page](/workspace/app/views/omniauth_callbacks/unknown_organisation_category.html.slim) when trying to sign-in in our service.

The most common cause for this is the Organisation having multiple entities with similar/same name in DfE Sign-in, and the publisher belonging/signing-in with an organisation that is not between our accepted list of org types.

The allowed org categories are listed in the `OmniauthCallbacksController::ORGANISATION_CATEGORIES`.

We usually confirm this by visiting the [Get Information About Schools (GIAS)](https://get-information-schools.service.gov.uk/) Service to retrieve the valid organisation UKPRN and request the Support Tearm to confirm with them they're signing-in with an Org with that UKPRN.
