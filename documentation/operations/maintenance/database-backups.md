# PostgreSQL Database Backups

## Azure Postgres automated backups
[Backups are automated](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-backup-restore) with daily snapshots and transaction logs allowing point-in-time restore.

## GitHub Actions-controlled backups to encrypted S3 bucket

Rationale: to avoid the edge case of a `terraform destroy` removing the PostgreSQL service, along with all its backups, we created a secured S3 bucket to allow additional nightly backups of the data. The uses have extended to allow on-demand backups, and on-demand restores to `staging` and `dev` environments.

Bucket folder:
- The bucket contains a "folder" (prefix): `full`

Retention policy
- these backups are retained for 7 days

Security
- we apply policies to [block public access to S3 storage](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)
- we add a deny policy to restrict the [ReadOnly](/documentation/operations/infrastructure/aws-roles-and-cli-tools.md) role from accessing the full backups

### Nightly backup

- The [Backup production database](https://github.com/DFE-Digital/teaching-vacancies/blob/main/.github/workflows/backup_production_db.yml) workflow runs nightly around 02:00 UTC
- Take a full backup
- Proves the integrity of the backup by restoring it to a temporary PostgreSQL environment
- Saves the full backup to S3

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
