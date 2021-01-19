# Authentication

Hiring staff authenticate via DfE Sign-in system. When onboarded you are associated with more than one organisation.

Different environments talk to different DfE Sign-in environments:

- Local development, Dev(GOV.UK PaaS) -> Test DfE Sign-in
- Staging(GOV.UK PaaS) -> Pre-production DfE Sign-in
- Production (GOV.UK PaaS) -> Production DfE Sign-in

Review apps use the magic link sent via email to authenticate.

## Configure DfE Sign-in Manage Service console

You need to request access to DfE Sign-in Manage Service console for that.

- [Test](https://test-manage.signin.education.gov.uk/services/E348F7D4-93D9-4B43-9B78-C84D80C2F34C)
- [Pre-production](https://pp-manage.signin.education.gov.uk/services/EF3E84E7-950A-4CB2-B1B0-66417F3CD5CA)
- [Production](https://manage.signin.education.gov.uk/services/E348F7D4-93D9-4B43-9B78-C84D80C2F34C)

From the console you can set the values of the following environment variables.

The following are set per-environment, e.g. [terraform/workspace-variables/dev_app_env.yml](../terraform/workspace-variables/dev_app_env.yml)

```
DFE_SIGN_IN_ISSUER: https://test-oidc.signin.education.gov.uk
DFE_SIGN_IN_REDIRECT_URL: https://dev.teaching-vacancies.service.gov.uk/auth/dfe/callback
DFE_SIGN_IN_URL: https://test-api.signin.education.gov.uk
```

Sensitive values are set per-environment in the [AWS Systems Manager Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table), e.g. `/teaching-vacancies/<env>/app/secrets`

```
DFE_SIGN_IN_IDENTIFIER=
DFE_SIGN_IN_PASSWORD=
DFE_SIGN_IN_SECRET=
DFE_SIGN_IN_SERVICE_ACCESS_ROLE_ID=
DFE_SIGN_IN_SERVICE_ID=
```
