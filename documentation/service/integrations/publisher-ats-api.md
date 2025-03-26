# Publisher ATS API

Publishers using ATS will be able to manage their vacancies through an API.

The API clients will be able to do these operations:
- Create a vacancy
- Retrieve a vacancy
- Update a vacancy
- Delete a vacancy
- List all their vacancies


## Onboarding new clients

To onboard new clients to the API, the technical process is as follows:

1. Set-up a dedicated review APP environment for the client integration.
2. On the review app environment, visit the `/support-users/publisher_ats_api_clients` endpoint and add a
new api client for the new integration. This will generate an **API token for the client**.
3. Go back to the client contact email and provide them with:

    - A **link to the ATS API docs** in their integration review app.

      EG: `https://teaching-vacancies-review-pr-7534.test.teacherservices.cloud/ats-api-docs/index.html`

    - The **HTTP credentials** for the review app.

    - The **base URL for their testing API**.

      EG: `https://teaching-vacancies-review-pr-7534.test.teacherservices.cloud/ats-api/v1`

    - The **API key** for their client.

The clients can build and test their client against the review app environment.

Once both parts are happy with the testing, we can move the integration to production.

### Releasing the new integration to production

1. Generate a new production API client in the [Support users Publisher ATS API Clients page](https://teaching-vacancies.service.gov.uk/support-users/publisher_ats_api_clients).
2. Provide the client with:

    - The ATS API **production endpoint URL**: `https://teaching-vacancies.service.gov.uk/ats-api/v1`

    - Their production **client API token**

    - A [link to the production ATS API docs](https://teaching-vacancies.service.gov.uk/ats-api-docs) that they can use as reference in the future.

    - The **HTTP credentials** for the API documentation (`SWAGGER_USERNAME`/`SWAGGER_PASSWORD` in our production secrets).

The client should be able to use start publishing vacancies in TV production by pointing their API client to the production endpoint URL and using the production client token.

## Maintaining the API documentation

We use [rswag](https://github.com/rswag/rswag) for documenting the API.

The API main description, schemas and examples are defined in the [swagger spec helper file](/spec/swagger_helper.rb)

The [vacancies request spec file](/spec/requests/publishers/ats_api/v1/vacancies_spec.rb) is also used for the documentation output and serves as integration test for the API endpoints.

The spec file is used to test the API endpoints behaviour in the CI [tests run](/.github/workflows/test.yml) and to generate the API documentation assets in the CI [build and deploy](/.github/workflows/build_and_deploy.yml).

The following command runs the integration tests and generates/updates the documentation:

`RAILS_ENV=test bundle exec rake rswag:specs:swaggerize`

## End-to-End Testing

Changes on the API must be manually tested end-to-end (ideally on a review app) before being released.

To do so:

1. Ensure the main [integration specs](/spec/requests/publishers/ats_api/v1/vacancies_spec.rb) pass.
2. Build a PR review app (or start the app locally for local testing) and visit the `/ats-api-docs/` path.
3. Click on the `Authorize` button and fill the `X-Api-Key` authorisation using the the api key defined in `ATS_API_CLIENT_TESTING_API_KEY` env variable.
4. Test the different API endpoint using their `Try it out` button, modifying each request payload as needed.
