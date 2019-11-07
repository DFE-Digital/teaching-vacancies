# Teacher Vacancy Service (TVS)

[API Documentation](https://docs.teaching-vacancies.service.gov.uk)

### Prerequisites
 - [Docker](https://docs.docker.com/docker-for-mac) greater than or equal to `18.03.1-ce-mac64 (24245)`

     We recommend you install Docker from the link above, _not_ using homebrew.

### Setting up the project

1. Copy the docker environment variables:

```bash
cp docker-compose.env.sample docker-compose.env
```

2. Navigate to the secrets repository, and [fill in][docs-to-read-secrets] any missing secrets from the [docker-compose.env.gpg][secret-docker-compose].

```
bin/pass secrets/dev/docker-compose.env > path/to/teacher-vacancy-service/docker-compose.env
```

3. [Follow these instructions to configure HTTPS](config/localhost/https/README.md)

4. Build the docker container, set up the database, and start the application at https://localhost:3000

```bash
bin/drebuild
```

[secret-docker-compose]:
https://github.com/DFE-Digital/teaching-vacancies-service-secrets/blob/master/secrets/dev/docker-compose.env.gpg
[docs-to-read-secrets]:
https://github.com/DFE-Digital/teaching-vacancies-service-secrets#reading-secrets

### Starting the application

```bash
bin/dstart
```

## User accounts & data

Before you can log in to the application locally you will need a __DfE Sign-in__ and an __invitation to join Teaching
Vacancies__. Talk to the team to get these set up.

### Importing school data

Populate your environment with real school data. This is taken from
[GIAS](https://get-information-schools.service.gov.uk/)

```bash
bin/drake data:schools:import
```

_db/seeds.rb contain sample school data so this is not required for development_

### Indexing the vacancies

Index the vacancies in Elasticsearch, both in the development and test environments

```bash
bin/drake elasticsearch:vacancies:index
```

## Running the tests

There are two ways that you can run the tests.

### In development

Because the setup and teardown introduces quite some latency, we use the spring service to start up all dependencies in
a docker container. This makes the test run faster.

Get the test server up and running
```bash
bin/dtest-server
```

Run the specs. When no arguments are specified, the default rake task is executed.

```bash
bin/dspec <args>
```

To run a single spec file, the `args` are simply the path to the desired spec file:line number, e.g.

```bash
bin/dspec spec/features/job_seekers_can_view_vacancies_spec.rb:23
```

### Full run (before you push to github)

Rebuilds the test server, runs rubocop checks, all tests (both specs and javascript) and cleans up.

```bash
bin/dtests
```

## Troubleshooting

_I see Page Not Found when I log in and try to create a job listing_

Try importing the school data if you have not already. When your sign in account was created, it was assigned to a
school via a URN, and you may not have a school in your database with the same URN.

_I get a connection error to Elasticsearch when I try to access the application locally_

It might be that the web server is attempting to connect to Elasticsearch before it has fully booted, despite
Elasticsearch being listed as a dependency for the webserver. Wait for a few minutes and try again.

_The application claims to have vacancies in the search results but I can't see them listed_

Run the Elasticsearch vacancies index task if you haven't already:

```bash
bin/drake elasticsearch:vacancies:index
```

## Running outside of docker

### Background

It may be useful to be able to run the codebase outside of the docker containers. For example, you might be working a
small VM or a slow machine and docker would introduce an unnecessarily high overhead.

### Dependencies

#### Baseline

```bash
Ruby 2.6.6
```

#### Services

Make sure you have the following services configured and running on your development background:

 * [Elasticsearch](https://elastic.co)
 * [Postgresql](https://postgresql.org)
 * [Redis](https://redis.io)

#### Test and development dependencies

 * [PhantomJS](https://phantomjs.org)

### Installation and setup

Once you have Postgresql running add a new user:

```bash
createuser --interactive --pwprompt
```

For running local development and test environments, you can safely grant the user superuser access when asked.  **DO
NOT** do this for production environments.

Feel free to use any other method you are familiar with for adding postgres users. This is only an example.

Next, copy `dotenv.sample` to `.env`, edit it and change:

```bash
DATABASE_URL=postgres://<user>:<password>@localhost/<desired-database-name>
```

Now, install your gem dependencies, then create and populate your database:

```bash
bundle
bundle exec rake db:create db:environment:set db:schema:load
```

Finally, run your tests:

```bash
bundle exec rake
```

If everything passes, you're ready to get to work.

### Misc

#### RSpec formatters - Fuubar

Fuubar is a fast-failing progress bar formatter for RSpec. I've added the gem, but know from experience it isn't to
everyone's taste. If you want to use it, either start RSpec with the formatter switch:

```bash
bundle exec rspec --format Fuubar
```

or add it to your global `~/.rspec`:

```bash
--format Fuubar
```
