# Teacher Vacancy Service (TVS)

### Prerequisites
 - [Docker](https://docs.docker.com/docker-for-mac)


### Setting up the project

Copy the docker environment variables and fill in any missing secrets:

```
$ cp docker-compose.dev.env.example docker-compose.dev.env
```

Build the docker container and set up the database

`bin/drebuild`


Start the application

`bin/dstart`

## Running the tests

There are two ways that you can run the tests.

### In development

Because the setup and teardown introduces quite some latency, we use the spring service to start up all dependencies in a docker container. This makes the test run faster.

Get the test server up and running
`bin/dtest-server`

Run the specs. When no arguments are specified, the default rake task is executed.
`bin/dspec <args>`

Run the javascript tests
`bin/dteaspoon

### Full run (before you push to github)

Rebuilds the test server, runs rubocop checks, all tests (both specs and javascript) and cleans up.

`bin/dtests`
