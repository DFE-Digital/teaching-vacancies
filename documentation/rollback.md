# Rollback

At the moment there is no automatic rollback option. Here are the manual steps required for each type of failure.

## Code
The simplest approach to rollback the code to a working version is to revert a pull request on GitHub. This will create a new PR that once is merged triggers a deploy. If that is not possible you need to manually checkout a working version of the code and deploy from your machine:

- Figure out the commit ID of the last working version
- Checkout the working version locally
    ```
    $ cd teacher-vacancy-service
    $ git pull
    $ git checkout <commit_id>
    ```
- If required, request elevated access to `SpaceDeveloper` role in the desired space
- Login to the desired space on GOV.UK PaaS
- Push the application

## Data
Ideally database schema changes are decorrelated from application deployments. So if one has to be rolled back, it doesn't impact the other.

### See current version of database
`cf7 run-task teaching-vacancies-production -c "rails db:version" --name dbversion && cf7 logs teaching-vacancies-production | grep dbversion`


### Rollback last n migrations
Given the current state of the database, figure out the version of the database you want to rollback to, and see how many steps you want to rollback.

`cf7 run-task teaching-vacancies-production -c "rails db:rollback STEP=n"`

If it's only the last migration that you are not happy with, remove `STEP=n`

Bear in mind that if a migration fails, the current state of the database will be the previous migration. The failing migration could have partially run, in that case you have to fix the data manually.


### Restore nightly backup
Create a **new** database using the latest snapshot of the RDS instance. See [GDS paas documentation](https://docs.cloud.service.gov.uk/deploying_services/postgresql/#restoring-a-postgresql-service-snapshot). This is a self-service option.

### Restore point-in-time backup
GDS have access to the RDS instances and can restore point-in-time with a resolution of 1 second. It's a manual process and must be requested from paas support.

### Restore from S3 backup
We keep our own nightly backups in S3. In case the RDS instance and all its backups are gone, we still have
this option.
* Recreate the empty database with terraform
* Get the latest backup from S3 bucket `530003481352-tv-db-backups`. They are gzipped SQL files with the date in the file name.
* Load the data into the new database. See: "Backup/Restore GOV.UK PaaS Postgres service database" in [GOV.UK PaaS](govuk-paas.md)
