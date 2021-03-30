# Offline site

## Location

The offline site is simple HTML, CSS, and assets (fonts and images). It sits in the `teaching-vacancies-offline` folder within the S3 bucket [530003481352-offline-site](https://s3.console.aws.amazon.com/s3/buckets/530003481352-offline-site?tab=objects).

With the [offline/index.html](../offline/index.html) page, paths to assets are declared from the root of the bucket, including the full folder name, e.g.:
```
/teaching-vacancies-offline/govuk-frontend.min.css
```

## When is it served?

The "site offline" page is served if Cloudfront detects that the PaaS-hosted site is returning HTTP status codes:
- [502 Bad Gateway](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/502)
- [503 Service Unavailable](https://developer.mozilla.org/en-US/docs/Web/HTTP/Status/503)

## How is it generated?

The [regenerate-offline](../bin/regenerate-offline) script:

- downloads and unzips a particular version of the [Gov.UK frontend](https://github.com/alphagov/govuk-frontend/releases/) into the [offline](../offline) folder
- renames the version-specific minified CSS file to `offline/govuk-frontend.min.css`
- does a search and replace to allow the site to be served from a sub-folder
- copies the `favicon.ico` from `/public/favicon.ico`

The [sync-offline](../bin/sync-offline) script:

- uses the AWS CLI to synchronise with the offline site S3 bucket

The GitHub Action [deploy](../.github/workflows/deploy.yml) workflow includes these steps:
- runs the regenerate-offline script
- runs the sync-offline script

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

## How to test

- Check the underlying page [in the S3 bucket](https://530003481352-offline-site.s3.eu-west-2.amazonaws.com/teaching-vacancies-offline/index.html)
- Check the page when served [through the site](https://dev.teaching-vacancies.service.gov.uk/teaching-vacancies-offline/index.html)
- Simulate an error on [https://dev.teaching-vacancies.service.gov.uk/](https://dev.teaching-vacancies.service.gov.uk/)
```bash
cf login --sso
cf target -s teaching-vacancies-dev
cf unbind-service teaching-vacancies-dev teaching-vacancies-postgres-dev
```
And after testing, re-bind:
```bash
cf bind-service teaching-vacancies-dev teaching-vacancies-postgres-dev
cf restart teaching-vacancies-dev
```
