# Teacher Vacancy Service (TVS)

## Ruby version
Requires Ruby 2.4.0

## System dependencies
- Postgres
- ElasticSearch
- PhantomJS

## Run tests and rubocop
`bundle exec rake`

## Populate School data
We have a Job that will fetch and populate our Postgres database from the Edubase archive. This has to be run manually and is not a scheduled task:

```
$ rails c
$ UpdateSchoolsDataFromSourceJob.perform_now
```

Initially this job returns data on 46454 schools.
