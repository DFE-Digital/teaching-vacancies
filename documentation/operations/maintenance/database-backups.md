# PostgreSQL Database Backups

## Azure Postgres automated backups
[Backups are automated](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-backup-restore) with daily snapshots and transaction logs allowing point-in-time restore.

### Nightly backup

- The [Backup production database](https://github.com/DFE-Digital/teaching-vacancies/blob/main/.github/workflows/backup_db.yml) workflow runs nightly around 04:00 UTC
- Take a full backup
- Saves the full backup to Azure Storage account

### Connect to the database
The `konduit.sh` script creates a tunnel connected to the database via the running application and allows using psql, pg_dump...

```shell
make bin/konduit.sh
make qa get-cluster-credentials
bin/konduit.sh teaching-vacancies-qa -- psql
```

For convenience when obtaining quick DB PSQL consoles, we have a script that maps to konduit internally:
```shell
bin/psql qa
```
