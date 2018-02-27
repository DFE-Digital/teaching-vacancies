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

## Testing

There are two ways that you can run the tests.

Using spring. This requires a running test server.

Get the test server up and running
`bin/dtest-server`

Run the specs. When no arguments are specified, the default rake task is executed.
`bin/dspec <args>`


Rebuild test server, run all tests and cleanup.

`bin/dtests`
