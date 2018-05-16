# Teacher Vacancy Service (TVS)

### Prerequisites
 - [Docker](https://docs.docker.com/docker-for-mac) greater than or equal to `18.03.1-ce-mac64 (24245)`


### Setting up the project

1. Copy the docker environment variables and fill in any missing secrets:

```
$ cp docker-compose.env.example docker-compose.env
```

2. Build the docker container and set up the database

```
bin/drebuild
```

3. [Follow these instructions to configure HTTPS](config/localhost/https/README.md)

4. Start the application

```
bin/dstart
```

## Running the tests

There are two ways that you can run the tests.

### In development

Because the setup and teardown introduces quite some latency, we use the spring service to start up all dependencies in a docker container. This makes the test run faster.

Get the test server up and running
`bin/dtest-server`

Run the specs. When no arguments are specified, the default rake task is executed.
`bin/dspec <args>`

Run the javascript tests
`bin/dteaspoon`

### Full run (before you push to github)

Rebuilds the test server, runs rubocop checks, all tests (both specs and javascript) and cleans up.

`bin/dtests`


## Importing school data (optional)

Populate your envirnoment with real school data from the Edubase archive

`bin/drake data:schools:import`

_db/seeds.rb contain sample school data so this is not required for development_
