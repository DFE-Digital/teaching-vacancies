# Service accounts
**Note: Following guidance is outdated. We do not use Google accounts anymore, as we have moved to Microsoft Outlook.**

Automated tasks should not be run by a human user for security reasons. Also the automation may break once the user leaves DfE and their credentials
are revoked.

Instead we create "service accounts" and use their credentials in automation. Service accounts are shared securely inside the team. Typically we
create a [Google group](https://groups.google.com/) with an explicit name, like `twd-tv-paas-non-prod@digital.education.gov.uk`. It provides an
email address which can be used to create a user in one or more services, like GOV.UK PaaS.

All members of the group have access to the group emails so they can all create new users or reset the password of existing users. Group owners
can add and remove members to the group.

Digital tools are responsible for creating and deleting Google groups. Request it in #digital-tools-support Slack channel.

Historically we've used the simple Google account teachingjobs@digital.education.gov.uk to register a number of service accounts
(see [API keys](api-keys.md)). Ideally these should be migrated to Google groups.

## GOV.UK PaaS service accounts
- twd-tv-paas-prod@digital.education.gov.uk
    - *SpaceManager* on production space to remove users automatically
    - *SpaceDeveloper* on production space to deploy the application
- twd-tv-paas-non-prod@digital.education.gov.uk
    - *SpaceDeveloper* on all non production spaces to deploy the application
- teaching-vacancies-monitoring@digital.education.gov.uk
    - *SpaceAuditor* on all spaces for monitoring to scrape paas metrics
    - *BillingManager* on dfe organisation foir monitoring to scrape BillingManager metrics
