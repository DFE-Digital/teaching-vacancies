# Disaster recovery

## Data loss:-

In the case of a data loss, we need to recovery the data as soon as possilbe in order to resume normal service.
The application's database is postgres instance, which resides on PaaS. The database is managed service - DB-as-Service.
The feature of the database that is applicable depends on tier. For instance, some database plans do not
have database backup features [postgres verions](https://admin.london.cloud.service.gov.uk/marketplace/4cb1521d-a914-4271-bfbf-84c27641d0c9).

The database instance in production is HA (High Availability) and fully backup every 5min. Hence the database can be recovered
from snapshot between the last 5min and 7days. The process of database data loss recovery has been into multiple `makefile`
targets:

	1.	`get-postgres-instance-guid`
	2.	`rename-postgres-service`
	3.	`remove-postgres-tf-state`
	4.	`restore-postgres`

In the instance of data loss, the following error would be displayed on the web application's page, dependiging on the environment:-

### Production\staging\dev\qa\research

`Sorry, there is a problem with the service Please try again later` - which originates from the s3 offline site

### Review app

`500 Internal Server Error`
`If you are the administrator of this website, then please read`
`this web application's log file and/or the web server's log`
`file to find out what went wrong`

(At this point, it would be application to set the application to maintenace mode, by setting `MAINTENANCE_MODE`.)

Once this has been done, the focus should then be on the remediating the database. The postgres instance, should still be available.
Use the makefile's `get-postgres-instance-guid` to get the database guid, for the affected space i.e. `qa`, `production` `staging`
etc - `make qa passcode=xxxx get-postgres-instance-guid`

Part of the remediation process to rename the affected database instance. Their is a makefile target (rename-postgres-service)
to achieve this - make qa passcode=xxxx CONFIRM_RENAME="yes" rename-postgres-service this rename the database by adding the "-old"
to the database name.

Once the database has been renamed, this would potential cause a significant drift from terrafrom, as terraform would not be able to
reconcile the database - via the statefile. If not already communicated, no one should merge to master, otherwise, terraform would
attempt the rename the database back to it was. To avoid, new need to remove the resouruce from the statefile. To achieve this,
use the makefile target (`remove-postgres-tf-state`). Also, the pipeline closed - any deployment via the pipeline at this would
cause a new instance of the database to be spawn. The aim of the disaster recovery is to spin a new instance of the database but using
a snapshot point-in-time-recovery (backup) of the corrupted instance database.

In order to create a new instance of the database with a point in time data-snapshot (backup) of the corrupted database, use makefile target
`restore-postgres`. The database guid should be automatically derived from `get-postgres-instance-guid` only the `SNAPSHOT_TIME` and `target_env`
variables should be set manually. The `SNAPSHOT_TIME` takes a `datetime` in the format of "2021-09-14 16:00:00". Once the makefile target `restore-postgres`
has been executed, this will create a new database instance but with a point-in-time database backup of affected database.
