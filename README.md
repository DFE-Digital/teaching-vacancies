# Teaching Vacancies Review

> Teaching Vacancies is a free job-listing service from the Department for Education. Teachers can
> search and apply for jobs at schools or trusts in England, save jobs and set up job alerts.

This repository contains the source code and infrastructure definitions for the main Teaching
Vacancies service, a Ruby on Rails application with PostgreSQL and Redis backing services.

## Onboarding

Welcome to the team! 🐯

You should have been added to our Github team ahead of time, if not, remind your delivery manager or
tech lead to do that and also [complete the other onboarding steps](documentation/onboarding.md)!

## Quick start

This project uses [devcontainers](https://code.visualstudio.com/docs/remote/create-dev-container)
to provide a seamless onboarding experience for developers and other team members.

You will need the following software installed on your system:
- [Git](https://github.com/git-guides/install-git)
- [Docker Desktop](https://www.docker.com/get-started)
  - You will need to start Docker before the process will work.
- [Visual Studio Code](https://code.visualstudio.com)

To get the application running:
- Clone the repository to a folder of your choice
- Ask another developer for a `.env` file, and place it in the root of the application folder
  (you can set up your AWS access to be able to do this yourself later)
- Open the folder in VS Code, and when prompted, choose "Reopen in container"
- The container will now build and execute first run tasks - this will take between 5 and 10 minutes
  depending on the performance of your computer. Wait for the terminal showing build tasks to
  display "`Done. Press any key to close the terminal.`"

When the build has finished, you can run the application by clicking on "▶️ Start app" in the status
bar. This will start:
- The Rails application running on http://localhost:3000
- Webpack Dev Server for fast reloading of frontend asset changes
- Sidekiq for processing background jobs

<details>
  <summary>Optional: Advanced custom setup (for developers)</summary>

  > The Docker-based devcontainer setup (see [configuration](.devcontainer)) is our "gold standard"
  > reference implementation of a local development environment. We highly recommend you use it, but
  > you're of course free to work in whatever way makes you the most happy and productive.
  >
  > This might involve running a container-based workflow using vanilla `docker-compose` (working
  > inside the container using a command-line text editor, or outside the container in a GUI editor
  > or IDE), running a Linux VM with a container engine for that extra bit of performance, or just
  > using the container definitions as a guide to setting the app up locally without any Docker
  > involvement at all.
</details>

* [API Documentation](https://docs.teaching-vacancies.service.gov.uk)
* [API Keys](/documentation/api-keys.md)
* [Continuous delivery](/documentation/continuous-delivery.md)
* [Deployments](/documentation/deployments.md)
* [Docker](/documentation/docker.md)
* [DSI Integration](/documentation/dsi-integration.md)
* [Hosting](/documentation/hosting.md)
* [Logging](/documentation/logging.md)
* [Onboarding](/documentation/onboarding.md)
* [Search](/documentation/search.md)
* [Disaster Recovery](/documentation/disaster-recovery.md)

---

## Additional setup

This section describes optional additional setup tasks once you have the application up and running.
It is mainly relevant for developers and not strictly necessary to run the application.

### AWS credentials, MFA, and role profiles

Once onboarded to AWS, you should finish setting up your account by following the steps described in
the [AWS roles and CLI tools documentation](/documentation/aws-roles-and-cli-tools.md).

### Environment Variables

Some environment variables are stored in [AWS Systems Manager Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table), some are stored in the repository.

Secrets (eg: API keys) are stored in AWS Systems Manager Parameter Store in `/teaching-vacancies/<env>/app/*` and `/teaching-vacancies/<env>/infra/*` files.

Non-secrets (eg: public URLs or feature flags) are stored in the repository in `terraform/workspace-variables/<env>_app_env.yml` files.

Run the following command to fetch all the required environment variables for development and output to a shell environment file:

```
aws-vault exec ReadOnly -- make -s local print-env > .env
```

[Git secrets](/documentation/secrets-detection.md) offers an easy way to defend against accidentally publishing these secrets.

## Data

If you use the devcontainer, the database will be created and seeded on first run using standard
`rails db:prepare`. The seeds generate a number of fake vacancies, job applications, and users,
as well as importing required data from a number of external services.

You shouldn't have to refresh the external data, but if you do need to, you can with the following
tasks:

```bash
# Import all schools, trusts, and local authorities from DfE's Get Information About Schools
bundle exec rails gias:import_schools

# Import location polygon data from the Office for National Statistics
bundle exec rails ons:import_all
```

If ever you want to start over, you can delete and re-seed using:

```bash
bundle exec rails db:drop db:prepare
```

The _SQLTools_ VS Code extension is installed and configured in the devcontainer by default and can
be used to browse the database and run SQL queries. The `psql` tool is also installed, so you can
use `rails dbconsole` or even just `psql tvs_development`.

## Tests and linting

The Rails application uses [RSpec](https://rspec.info) and [RuboCop](https://rubocop.org) for
testing and linting, as well as [Brakeman](https://brakemanscanner.org) for security scanning and
[Slim-Lint](https://github.com/sds/slim-lint) to lint Slim templates.

```bash
# Run tests and linting
bundle exec rake

# Run tests only
bundle exec rspec

# Run linters only
bundle exec rails lint
```

The frontend Javascript code uses [Jest](https://jestjs.io) and [ESLint](https://eslint.org/) for
testing and linting (using [Airbnb rules](https://www.npmjs.com/package/eslint-config-airbnb)), as
well as [Stylelint](https://stylelint.io/) for SASS linting (with the default ruleset):

```bash
# Run tests and linting
yarn test

# Run tests only
yarn run js:test

# Generate a coverage report
yarn run js:test:coverage

# Run JS linter only
yarn run js:lint

# Run SASS linter only
yarn run sass:lint
```
