# Teacher Vacancy Service (TVS)

### Prerequisites
 - [Docker](https://docs.docker.com/docker-for-mac) greater than or equal to `18.03.1-ce-mac64 (24245)`

We recommend you install Docker from the link above, _not_ using homebrew.

### Setting up the project

1. Copy the docker environment variables and fill in any missing secrets from the TeachingJobs 1Password vault:

```bash
$ cp docker-compose.env.sample docker-compose.env
```

2. Build the docker container and set up the database

```bash
bin/drebuild
```

3. [Follow these instructions to configure HTTPS](config/localhost/https/README.md)

4. Start the application

```bash
bin/dstart
```

## User accounts & data

Before you can log in to the application locally you will need a __DfE Sign-in__ and an __invitation to join Teaching Vacancies__. Talk to the team to get these set up.

### Importing school data

Populate your environment with real school data. This is taken from [GIAS](https://get-information-schools.service.gov.uk/)

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

Because the setup and teardown introduces quite some latency, we use the spring service to start up all dependencies in a docker container. This makes the test run faster.

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

Run the javascript tests
```bash
bin/dteaspoon
```

### Full run (before you push to github)

Rebuilds the test server, runs rubocop checks, all tests (both specs and javascript) and cleans up.

```bash
bin/dtests
```

## Troubleshooting

_I see Page Not Found when I log in and try to create a job listing_

Try importing the school data if you have not already. When your sign in account was created, it was assigned to a school via a URN, and you may not have a school in your database with the same URN.

_I get a connection error to Elasticsearch when I try to access the application locally_

It might be that the web server is attempting to connect to Elasticsearch before it has fully booted, despite Elasticsearch being listed as a dependency for the webserver. Wait for a few minutes and try again.

_The application claims to have vacancies in the search results but I can't see them listed_

Run the Elasticsearch vacancies index task if you haven't already:

```bash
bin/drake elasticsearch:vacancies:index
```
