# GitHub Actions

## Secrets

> [GitHub Actions Encrypted Secrets](https://docs.github.com/en/actions/reference/encrypted-secrets) are environment variables that are encrypted and only exposed to selected actions. Anyone with collaborator access to this repository can use these secrets in a workflow.
>
> Secrets are not passed to workflows that are triggered by a Pull Request from a fork.

### Secret lifecycle

All scerets are stored on AWS parameterstore, with the exception of `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, which are needed to bootstrap Github Action's workflow. With sufficient privileges, these are available under [Settings/Secrets](https://github.com/DFE-Digital/teaching-vacancies/settings/secrets)

Secrets may be:
- Added
- Updated
- Removed

Secrets can not be decrypted/viewed through the web portal, but only through workflows.
