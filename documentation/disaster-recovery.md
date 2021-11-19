# Disaster recovery

## Data loss

In the case of a data loss, we need to recover the data as soon as possible in order to resume normal service.
The application's database is a postgres instance, which resides on PaaS. This provides a point-in-time backup with
the resolution of 1 second, available between 5min and 7days ago - this is not applicable to postgres `tiny` plans. We can use
terraform to create a new database using a point-in-time backup of the affacted database instance.

### Make note of database failure time

Make note of the time the database failure occurred, and then use this to calculate when the integrity of the data in the database was still viable. For instance,
if data loss or corruption happened at 1200hrs, workout what snapshot time is best for the product. This would determine the value of `SNAPSHOT_TIME` env.

### Freeze pipeline

If not already communicated, no one should merge to master branch

### Maintenance mode

In the instance of data loss, if the application is unavailable, the offline site may be displayed.
If the application is still available and there is a risk of users adding data, enable the maintenace mode, by setting [Maintenance mode](maintenance-mode.md).

### Get postgres database ID

Use the makefile's `get-postgres-instance-guid` to get the database guid, use the following command:

```
make production get-postgres-instance-guid passcode=xxxx CONFIRM_PRODUCTION=true
```


### Rename postgres databas instance service

Part of the remediation process is to rename the affected database instance so it can be recreated with the production name. There is a makefile target (rename-postgres-service)
to achieve this -

```
make production rename-postgres-service passcode=xxxx CONFIRM_PRODUCTION=true
```
this renames the database by adding the "-old" to the database name.

### Remove postgres database instance from terraform state file

In order for terraform to be able to create a new database instance, the existing database reference needs to be removed from the state file. This is to ensure it is no longer managed by terraform. To achieve this, use the makefile target -

```
make production remove-postgres-tf-state CONFIRM_PRODUCTION=true
```

### Restore postgres database instance

The following variables need to be set: `get-postgres-instance-guid`, `DB_INSTANCE_GUID` and `SNAPSHOT_TIME` ("2021-09-14 16:00:00" IMPORTANT - this is UTC time!), `passcode=xxxxx` `CONFIRM_PRODUCTION=true`

 Use the following makefile command to initiate the restore process -
 ```
 make production restore-postgres DB_INSTANCE_GUID=abcdb262-79d1-xx1x-b1dc-0534fb9b4 SNAPSHOT_TIME="2021-11-16 15:20:00" passcode=xxxxx CONFIRM_PRODUCTION=true
 ```
 this will create a new database instance but with a point-in-time database backup of affected database.
