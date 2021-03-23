# Teaching Vacancies

* [API Documentation](https://docs.teaching-vacancies.service.gov.uk)
* [API Keys](/documentation/api-keys.md)
* [Continuous delivery](/documentation/continuous-delivery.md)
* [Deployments](/documentation/deployments.md)
* [Docker](/documentation/docker.md)
* [DSI Integration](/documentation/dsi-integration.md)
* [Hosting](/documentation/hosting.md)
* [Logging](/documentation/logging.md)
* [Onboarding](/documentation/onboarding.md)
* [Misc](#misc)
* [Search](/documentation/search.md)
* [Troubleshooting](#troubleshooting)

## Setup

Welcome! :tada: :fireworks:

By now you should be [onboarded](/documentation/onboarding.md).

The first thing to do is to install the required development tools. If you are on a Mac, this [script](https://github.com/thoughtbot/laptop) will install Homebrew, Git, asdf-vm, Ruby, Bundler, Node.js, npm, Yarn, Postgres, Redis and other useful utilities.

Then, clone the project with SSH:

```bash
git clone git@github.com:DFE-Digital/teaching-vacancies.git
```

If you are on a new device, remember to [generate a new SSH key](https://docs.github.com/en/github/authenticating-to-github/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).

### Dependencies

* [Ruby](https://www.ruby-lang.org)
* [NodeJS](https://nodejs.org)

A tool like [asdf-vm](https://asdf-vm.com) can help you install the required versions of Ruby and Node.js.
Current versions that match production ones are specified in [.tool-versions](/.tool-versions).

If asdf-vm is installed correctly, from the project repository you can just execute:

```bash
asdf install
```

### Services

Make sure you have the following services configured and running on your development background:

* [PostgreSQL](https://www.postgresql.org)
* [Redis](https://redis.io)


### ChromeDriver

To install
```bash
brew install --cask chromedriver
```

To update
```bash
brew upgrade --cask chromedriver
```

On macOS you might need to "un-quarantine" chromedriver too
```bash
which chromedriver
xattr -d com.apple.quarantine /path/to/chromedriver
```

### AWS credentials, MFA, and role profiles

When onboarded, you will be provided with an AWS user. You can use it to access the AWS console at:
[https://teaching-vacancies.signin.aws.amazon.com/console](https://teaching-vacancies.signin.aws.amazon.com/console).

[Set up MFA and install command-line tools](/documentation/aws-roles-and-cli-tools.md)

### Environment Variables

Some environment variables are stored in [AWS Systems Manager Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table), some are stored in the repository.

Secrets (eg: API keys) are stored in AWS Systems Manager Parameter Store in `/teaching-vacancies/<env>/app/*` and `/teaching-vacancies/<env>/infra/*` files.

Non-secrets (eg: public URLs or feature flags) are stored in the repository in `terraform/workspace-variables/<env>_app_env.yml` files.

Run the following command to fetch all the required environment variables for development and output to a shell environment file:

```
aws-vault exec ReadOnly -- make -s local print-env > .env
```

To run the command above you need [AWS credentials](#aws-credentials-mfa-and-role-profiles).

[Git secrets](/documentation/secrets-detection.md) offers an easy way to defend against accidentally publishing these secrets.

For local development, you can use a [dotenv-rails environment override](https://github.com/bkeepers/dotenv#frequently-answered-questions):
- create the file `.env.local`, with contents `DOMAIN=localhost:3000`

### Install dependencies

Install Ruby dependency libraries:

```bash
bundle
```

Install Javascript dependency libraries:

```bash
yarn
```

### Setup the database

```bash
bundle exec rails db:create db:schema:load
```

[/config/database.yml](./config/database.yml) sets the default for `DATABASE_URL` to `postgres://postgres@localhost:5432`, which should work without any additional configuration on a Mac

If you set up your local Postgres with a custom user and password, such as in Ubuntu 20.04, set this in `.env.local`:
```
DATABASE_URL=postgres://mylocaluser:mylocalpassword@localhost:5432
```


### Seeding the database

To create a few vacancies in your database run:

```bash
bundle exec rails db:seed
```

### Importing data

#### GIAS data (schools, trusts and local authorities)

Populate your environment with real school data. This is taken from
[GIAS](https://get-information-schools.service.gov.uk/). It might take a while, so make a cup of tea while you wait.

```bash
bundle exec rails gias:import_schools
```

#### ONS Location polygons

Run these rake tasks to populate your database with location polygons (which are used in some cases to search by location).

```bash
bundle exec rails ons:import_location_polygons
```

### Run the server

```bash
bundle exec rails server
```

Look at that, you’re up and running! Visit [http://localhost:3000](http://localhost:3000) and you’re ready to go.

### Run the worker

```bash
bundle exec sidekiq -C config/sidekiq.yml
```

### Run the tests

#### Ruby

This uses a standard `RSpec` and `RuboCop` stack. To run these together:

```bash
bundle exec rake
```

To run only RSpec:

```bash
bundle exec rspec
```

To run only RuboCop:

```bash
bundle exec rubocop
```

#### JavaScript

```bash
npm test
```

The full test suite including linting can be run as parallel tasks using the command:

```bash
yarn test
```

To run unit tests written using [Jest](https://jestjs.io/):

```bash
yarn run js:test
```

To generate a coverage report of unit tests you can run:

```bash
yarn run js:test:coverage
```

Linting of Javascript files uses [ESLint](https://eslint.org/) and the ruleset is extended using [Airbnb rules](https://www.npmjs.com/package/eslint-config-airbnb) which are widely acknowledged as a comprehensive ruleset for modern Javascript. To run Javascript linting:

```bash
yarn run js:lint
```

#### SASS

Linting of SASS files uses [Stylelint](https://stylelint.io/) default ruleset and can be run using:

```bash
yarn run sass:lint
```

---

## Troubleshooting

* I see Page Not Found when I log in and try to create a job listing.

Try [importing the school data](#gias-data-schools-trusts-and-local-authorities) if you have not already. When your sign in account was created, it was assigned to a school via a URN, and you may not have a school in your database with the same URN.

---

## Misc

### Getting production-like data for local development

You can use conduit to create a dump of production data. See [this section](/documentation/hosting.md#backuprestore-govuk-paas-postgres-service-database) of the GovUK PaaS docs. Then you can load this into your local database:

```bash
psql tvs_development < backup.sql
```

### Integration between Jira and Github

The integration allows to see the status of development from within the jira issue. You can see the
status of branches, commits and pull requests as well as navigate to them to show the detail in Github.

To enable this, the following formatting must be used:
- Branch: Prefix with the issue id. Ex: `TEVA-1155-test-jira-github-integration`
- Commit: Prefix with the issue id between square bracket. Ex: `[TEVA-1155] Update Readme`
- Pull request: Prefix with the issue id between square bracket. If the branch was prefixed correctly,
this should be automatically added for you. Ex: `[TEVA-1155] Document Jira-Github integration`

The branch, commit or pull request will then appear in the `Development` side panel within the issue.
