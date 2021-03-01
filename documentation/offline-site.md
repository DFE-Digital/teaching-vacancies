# Offline site

## When is it served?

The "site offline" page is served if Cloudfront detects that the PaaS-hosted site is returning HTTP status codes:
- [502 Bad Gateway](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/502)
- [503 Service Unavailable](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/503)

## How is it generated?

The [regenerate-offline](../bin/regenerate-offline) script:

- downloads and unzips a particular version of the [Gov.UK frontend](https://github.com/alphagov/govuk-frontend/releases/) into the [offline](../offline) folder
- renames the version-specific minified CSS file to `offline/govuk-frontend.min.css`
- copies the `favicon.ico`

The GitHub Action [deploy](../.github/workflows/deploy.yml) workflow includes these steps:
- run the regenerate-offline script
- use the AWS CLI to synchronise with the offline site S3 bucket

## How to update

### Edit the offline page

The offline page is a single HTML file in [offline/index.html](../offline/index.html)

### Update the version of the Gov.UK frontend

- Check for a new release of the [Gov.UK frontend](https://github.com/alphagov/govuk-frontend/releases/)
- Set the release in the [regenerate-offline](../bin/regenerate-offline) script
```
RELEASE=3.11.0
```
- When the change is merged, the new version will be synchronised
