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

You can run the specs using `bin/dspec`.
When no arguments are specified, the default rake task is executed.
