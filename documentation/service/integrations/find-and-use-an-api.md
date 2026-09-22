# Find and Use an API (FaUAPI)

[Find and Use an API](https://beta-find-and-use-an-api.education.gov.uk) is the Department for
Education's API catalogue and API management platform. Listing public-facing APIs there is a
departmental requirement, so the [Publisher ATS API](publisher-ats-api.md) has a catalogue entry.

FaUAPI is a listing, not something the service depends on. The documentation we give ATS clients
is still the Swagger UI at `/ats-api-docs`, and the catalogue entry exists so the API is
discoverable across DfE.

## How it works

On every deploy of `main`, after the smoke test passes, the
[build and deploy workflow](/.github/workflows/build_and_deploy.yml) runs
`bundle exec rake fauapi:publish` inside the deployed web pod, for staging and production only.
That task:

1. Reads the OpenAPI document at `swagger/v1/swagger.yaml`
   ([`FindAndUseAnApi::BuildManifest`](/app/services/find_and_use_an_api/build_manifest.rb)) and
   base64-encodes it into a manifest describing the API.
2. Imports the manifest into FaUAPI and publishes the resulting catalogue entry
   ([`FindAndUseAnApi::PublishCatalogue`](/app/services/find_and_use_an_api/publish_catalogue.rb),
   [`FindAndUseAnApi::Client`](/app/lib/find_and_use_an_api/client.rb)).

The OpenAPI document is gitignored — it is generated in CI by the `swagger-gen` job and baked
into the Docker image. Publishing from inside the pod is what guarantees the catalogue describes
the code that is actually deployed.

The import is an upsert keyed on name plus major version, so republishing an unchanged manifest
on every deploy is harmless.

**A failure here never fails a deploy.** The step is `continue-on-error` and notifies the
`twd_tv_dev` Teams channel instead. The next deploy republishes.

## Environments

| Our environment | FaUAPI instance | Catalogue |
| --- | --- | --- |
| staging | `https://pp-apimanagement.education.gov.uk` | https://pp-find-and-use-an-api.education.gov.uk |
| production | `https://apimanagement.education.gov.uk` | https://beta-find-and-use-an-api.education.gov.uk |

Local, review and QA have publishing switched off.

## Configuration

| Variable | Where it lives | Notes |
| --- | --- | --- |
| `FAUAPI_PUBLISHING` | `terraform/workspace-variables/<env>_app_env.yml` | `true` for staging and production only. Backs the `FauapiPublishing` flag in `config/initializers/flags.rb` |
| `FAUAPI_BASE_URL` | `terraform/workspace-variables/<env>_app_env.yml` | The API management host for that FaUAPI instance |
| `FAUAPI_API_KEY` | AWS Parameter Store, `/teaching-vacancies/<env>/app/secrets` | The "Automation Token" from the FaUAPI workspace |

The token is issued per workspace from the FaUAPI UI. To rotate it:

```bash
aws-vault exec <profile> -- make staging edit-app-secrets
aws-vault exec <profile> -- make production edit-app-secrets
```

## Publishing by hand

Use the interactive `rake` target, which selects the right Azure subscription for you:

```bash
make staging rake task=fauapi:publish
make production rake task=fauapi:publish CONFIRM_PRODUCTION=YES
```

The deploy workflow uses `make <env> ci ci-rake task=fauapi:publish` instead: `ci-rake` works
without a TTY, and `ci` relies on the Azure login the workflow has already done. Don't use that
form from a laptop.

To inspect the manifest without publishing anything:

```bash
bundle exec rake fauapi:manifest
```

Validate that output against the
[FaUAPI Automation API schema](https://pp-apimanagement.education.gov.uk/api/schema/index.html)
whenever you change the manifest — the
[DfE guidance](https://tech-docs.teacherservices.cloud/documenting-an-api/documenting-sd-apis-in-fauapi.html#automating-fauapi-publication)
asks for this, and it is the cheapest way to catch a wrong field name.

## Adding a second API version

`BuildManifest` builds one manifest for `v1`. FaUAPI keys entries on name plus major version, so
a `v2` of the ATS API needs one manifest per major version, each with its own `releases` list and
embedded schema. The
[register-trainee-teachers implementation](https://github.com/DFE-Digital/register-trainee-teachers/blob/main/app/services/find_and_use_an_api/build_manifests.rb)
does exactly that and is worth copying at that point.
