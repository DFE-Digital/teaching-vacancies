# Rollback

It is possible to [deploy a specific tag to an environment](deployments.md#deploy-a-specific-tag-to-an-environment---github-actions).

If you need to rollback manually, here are the steps required for each type of failure.

## Code
The simplest approach to rollback the code to a working version is to revert a pull request on GitHub. This will create a new PR that once is merged triggers a deploy.

## Data
Ideally database schema changes are decorrelated from application deployments. So if one has to be rolled back, it doesn't impact the other.

### See current version of database
`make production rake task=db:version CONFIRM_PRODUCTION=YES`


### Rollback last n migrations
Given the current state of the database, figure out the version of the database you want to rollback to, and see how many steps you want to rollback.

`make production rake task=db:rollback STEP=n CONFIRM_PRODUCTION=YES`

If it's only the last migration that you are not happy with, remove `STEP=n`

Bear in mind that if a migration fails, the current state of the database will be the previous migration. The failing migration could have partially run, in that case you have to fix the data manually.


### Restore nightly backup
TBD

### Restore point-in-time backup
TBD

### Restore from S3 backup
TBD
