# PostgreSQL Database Backups

## Gov.UK PaaS automated backups

From the [Gov.UK PaaS PostgreSQL page](https://docs.cloud.service.gov.uk/deploying_services/postgresql/):
> Backups are taken nightly at some time between 22:00 and 06:00 UTC. Data is retained for 7 days.
>
> - You can [restore to the latest snapshot](https://docs.cloud.service.gov.uk/deploying_services/postgresql/#restoring-a-postgresql-service-snapshot).
> - You can [restore to any point from 5 minutes to 7 days ago](https://docs.cloud.service.gov.uk/deploying_services/postgresql/#restoring-a-postgresql-service-from-a-point-in-time), with a resolution of one second.

## GitHub Actions-controlled backups to encrypted S3 bucket

Rationale: to avoid the edge case of a `terraform destroy` removing the PostgreSQL service, along with all its backups, we created a secured S3 bucket to allow additional nightly backups of the data. The uses have extended to allow on-demand backups, and on-demand restores to `staging` and `dev` environments.

Full vs sanitised

- The bucket contains two "folders" (prefixes) which are `full` and `sanitised`

Retention policy
- these backups are retained for 7 days

Security
- we apply policies to [block public access to S3 storage](https://docs.aws.amazon.com/AmazonS3/latest/userguide/access-control-block-public-access.html)
- we add a deny policy to restrict the [ReadOnly](./aws-roles-and-cli-tools.md) role from accessing the full backups

Sanitisation
- we run the [sanitise.sql](../db/scripts/sanitise.sql) script to:

    - TRUNCATE certain tables
    - Anonymise names and email addresses
    - Use a smaller database in `staging` and `dev` environments

### Nightly backup

- The [Sync staging database](https://github.com/DFE-Digital/teaching-vacancies/actions/workflows/lint.yml) workflow runs nightly around 02:30 UTC
- Take a full backup
- Proves the integrity of the backup by restoring it to a temporary PostgreSQL environment
- Saves the full backup to S3
- Runs the [sanitise.sql](../db/scripts/sanitise.sql) script
- Saves the sanitised backup to S3

### Restore sanitised backup to `staging` or `dev` environments

List just the file names in the `sanitised` folder:

```bash
aws-vault exec ReadOnly -- aws s3 ls s3://530003481352-tv-db-backups/sanitised/ | awk '{print $4}'
```

- Select the sanitised backup you wish to restore, e.g. `2021-03-03-02-48-14-sanitised.sql.gz`
- Go to the [Restore dev/staging db from production backup](https://github.com/DFE-Digital/teaching-vacancies/actions/workflows/restore_db.yml) workflow
- Select the environment (defaults to `dev`)
- Enter the filename of the sanitise backup
- Click `Run workflow`

### Take an additional backup before a potentially-destructive action

Rationale

- to offer a quick way of making an additional backup without having to grant SpaceDeveloper permissions to the `teaching-vacancies-production` space.

Steps

- Run the GitHub Actions workflow

## Work with backups interactively with cf conduit

Permissions required
- SpaceDeveloper role on Gov.UK PaaS spaces

### Install Conduit plugin

```bash
cf install-plugin conduit
```

### Backup

```bash
cf conduit $CF_POSTGRES_SERVICE_ORIGIN -- pg_dump -x --no-owner -c -f backup.sql
```

### Restore

```bash
cf conduit $CF_POSTGRES_SERVICE_TARGET -- psql < backup.sql
```
