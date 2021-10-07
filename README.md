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

Welcome! :tada: :fireworks: :tiger:

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
* shared-mime-info (installed using Homebrew or other package manager of your choice, the
  `mimemagic` gem depends on this)

A tool like [asdf-vm](https://asdf-vm.com) can help you install the required versions of Ruby and Node.js.
Current versions that match production ones are specified in [.tool-versions](/.tool-versions).

If asdf-vm is installed correctly, from the project repository you can just execute:

```bash
asdf install
```

If `asdf install` fails with the below message, and you are on a Mac, install [GPG Suite](https://gpgtools.org/).

```
You must install GnuPG to verify the authenticity of the downloaded archives before continuing with the install: https://www.gnupg.org/
```

### Services

Make sure you have the following services configured and running on your development background:

* [PostgreSQL](https://www.postgresql.org)
* [Postgis](https://postgis.net/install/)
* [Redis](https://redis.io)

If using Homebrew to install PostgreSQL, run `brew services start postgresql` in order to have `launchd` start PostgreSQL and restart whenever you log in.

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

### Install dependencies

#### Install Ruby dependency libraries

```bash
bundle
```

Install the version of Bundler that created the lockfile if prompted to do so.

#### Install Javascript dependency libraries

```bash
yarn
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

#### Override variables for local development

For local development, you can use a [dotenv-rails environment override](https://github.com/bkeepers/dotenv#frequently-answered-questions):
- create the file `.env.local`, with contents
```
DFE_SIGN_IN_REDIRECT_URL=http://localhost:3000/publishers/auth/dfe/callback
DOMAIN=localhost:3000
LOCKBOX_MASTER_KEY=0000000000000000000000000000000000000000000000000000000000000000
```

### Set up the database

```bash
bundle exec rails db:create db:schema:load
```

[/config/database.yml](./config/database.yml) sets the default for `DATABASE_URL` to `postgis://postgres@localhost:5432`, which should work without any additional configuration on a Mac.

If you set up your local Postgres with a custom user and password, such as in Ubuntu 20.04, set this in `.env.local`:
```
DATABASE_URL=postgis://mylocaluser:mylocalpassword@localhost:5432
```

⚠ Note that the database URL has `postgis` as its adapter, not `postgres`!


### Seed the database

Populate your environment with real school data, taken from [GIAS](https://get-information-schools.service.gov.uk/):

```bash
bundle exec rails gias:import_schools
```

Then you can run the standard `db:seed` task to populate the database with publishers, vacancies, jobseekers and job applications:

```bash
bundle exec rails db:seed
```

#### ONS Location polygons

Run these rake tasks to populate your database with location polygons. These are required in some cases to search by location.

```bash
bundle exec rails ons:import_location_polygons
```

### Run the server

```bash
bundle exec rails server
```

Look at that, you’re up and running! Visit [http://localhost:3000](http://localhost:3000) and you’re ready to go.

#### Use live reloading

Optionally, use live reloading with [bin/webpack-dev-server](https://github.com/DFE-Digital/teaching-vacancies/blob/master/bin/webpack-dev-server) to save time when developing front-end assets:

```
yarn run dev
```

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

Try [seeding the database](https://github.com/DFE-Digital/teaching-vacancies#seed-the-database) (quick) or [importing the school data](#gias-data-schools-trusts-and-local-authorities) (slow) if you have not already. When your sign in account was created, it was assigned to a school via a URN, and you may not have a school in your database with the same URN.

---

## Misc

### Getting production-like data for local development

To get sanitised production-like data for local development, first log in to AWS with the ReadOnly role. To do so, follow the instructions here: [AWS Login](/documentation/aws-roles-and-cli-tools.md#log-in-to-the-aws-console-with-aws-vault).

Once logged in, go to S3 >  530003481352-tv-db-backups > sanitised. Then click the checkbox next to the backup you want (the names of the backups will include dates) and click "Download".

Then, unzip the file and load it into your local database like so:

```bash
  psql tvs_development < <path to unzipped .sql backup file>
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
