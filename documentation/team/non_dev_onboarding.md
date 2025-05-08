# Onboarding team members

This document explains the steps to give access to our environments to **non-developers**.

For developers onboarding, use [the following document](/documentation/team/developer_onboarding.md).


## Who should follow these steps

**Any TV developer** should have enough permissions to do the following steps.

## Service Seeds

This will provide access to the review environments and QA as a jobseeker.

Add the new member to the [seeds file user list](/db/seeds.rb).

## GovUK Notify

New members will need this to be able to receive emails on testing environments.

Add the new member to the [GovUK Notify team DfE Teaching Vacancies](https://www.notifications.service.gov.uk/services/786d369d-11d1-4c7e-9a11-ef06aab2978b/users/invite) team.


## DfE Sign-in

### Hiring staff user in test environment:

New members will get access as hiring staff to the [Teaching Vacancies QA environment site](https://qa.teaching-vacancies.service.gov.uk/).

To do so, a TV developer will sign-in to [DfE Sign-in test environment](https://test-interactions.signin.education.gov.uk) and invite the new team member to the following organisations as a hiring staff user:

* Bexleyheath Academy (school)
* WEYDON MULTI ACADEMY TRUST (trust)
* Southampton (local authority)
* Weydon School (school)


### [Optional] Production Support user:

The new team member may need access to the [Teaching Vacancies production support dashboard](https://teaching-vacancies.service.gov.uk/support-users), that provides access to the [production user feedback](https://teaching-vacancies.service.gov.uk/support-users/feedback/general).

To provide it, a TV developer will sign-in to [DfE Sign-in production environment](https://services.signin.education.gov.uk/) and invite the new team member to Teaching Vacancies support team.


## [Optional] Github Codespaces access for content team members

We provide content team members a cloud development environment through [Github Codespaces](https://docs.github.com/en/codespaces).
The codespaces are built using our [Devcontainer setup](/documentation/development/tooling/devcontainer.md)

Onboarding a new team member to TV project codespaces:

1. Ensure the team member has a Github user and is a member of [DFE-Digital organisation](https://github.com/orgs/DFE-Digital/teams).

2. The team member must have individual write access (not only by a team membership) in the [project access settings](https://github.com/DFE-Digital/teaching-vacancies/settings/access).

3. Request codespace access for the team member through the [DFE Service Portal](https://dfe.service-now.com.mcas.ms/serviceportal?id=sc_cat_item&sys_id=0aacf3a81ba52110b192ec69b04bcb14) under `GitHub (dfe-digital) -> Other`.


    **Request content template**
    > Add a new user to organisation-owned Codespaces for Teaching Vacancies service.
    >
    > A new Teaching Vacancies content team member needs access to the DFE Digital-paid codespaces.
    >
    > Our project: https://github.com/DFE-Digital/teaching-vacancies
    >
    > The user: @user_github_handle
    >
    > Thank you.

4. Once the ticket gets actioned, the user should be able to create codespaces from the `Code -> Codespaces` green button in our Github project landing page.

