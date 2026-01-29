# BAU tasks

### Fixing the "Permission denied. Failed to verify the URL ownership." error

1. Visit [webmaster_central] and login using the "teachingjobs@digital.education.gov.uk" account details
from the secrets repo.

2. Click add an owner for: "analytics-prod@teacher-vacancy-service.iam.gserviceaccount.com"

[webmaster_central]: https://www.google.com/webmasters/verification/details?hl=en&siteUrl=https://teaching-vacancies.service.gov.uk/&authuser=3&mesd=ACQ0Nr_qx9U2vbqOrgcxCOE4aFyfB_GW-g6bpYPCnkxgHBU_6VaQ_VuatrdgmiW5ABZQMpTHrtERgmvhOB04uji-_nAlH6WkBSaMlpKO2Jk5N1VU7L8DcIJHvokNamPH2rmTcnvHuK6mGBWYiMT35ED0FjbrgZHFrWwFgjpAVvnhaKAtoEmVL25dnyo2XQt05pJe1yN7guWswWfafEYIGoe5Q-k4WNsJtQ


### Backfilling a database table into our Analytics platform

**Alert:** These commands will queue one async job for every 500 instances to upload.
 Depending on the volume of entities to push, we may need to execute these commands out of office hours or/and increase the number of production workers before executing them.

To increase the production workers, read the [hosting documentation](/documentation/operations/infrastructure/hosting.md#temporally-scaling-up-our-deployment-instances)

For backfilling a table into analytics, execute in a **production** console:
```
bundle exec rails dfe:analytics:import_entity[table_name]
```

For backfilling the whole DB into analytics (**very resource/time intensive**), execute in a production console:
```
bundle exec rails dfe:analytics:import_all_entities
```

### Copying files from a kubernetes pod to the developer machine

[Article](https://spacelift.io/blog/kubectl-cp) with detailed instructions and examples.

`kubectl cp -n <namespace> <pod-name>:<path> <destination-on-local-system>`

Example:
`kubectl cp -n tv-development  teaching-vacancies-review-pr-7433-744c5c9b4b-ckxxd:jobseeker_emails.txt ./file.txt`

### Exporting SQL query outputs from service DB to the developer machine as CSV file

You will need konduit
If not already setup, you can install it using the project Makefile. From the project's root:
```
make bin/konduit.sh
```
Connect to the DB PSQL console on the desired env/review-app:
```
bin/psql qa
bin/psql staging
bin/psql production
bin/psql pr-8476
```

From the PSQL console, execute a query:
```
COPY (
  SELECT column/s
  FROM table
  WHERE condition
) TO '/local/path/filename.csv' WITH CSV HEADER;
```

### Running schedule tasks on demand

We now and then want to execute a [scheduled rake task](/config/schedule.yml) on demand.

Unless for particular debugging reasons, there is no need to do this from a production rails console.

They can be triggered from the Sidekiq dashboard, accessible with your work email through DfE Sign-in.
[Link to Sidekiq dashboard in production](https://teaching-vacancies.service.gov.uk/sidekiq)

Once in the dashboard, the [Cron tab](https://teaching-vacancies.service.gov.uk/sidekiq/cron) lists all the schedule jobs,
where they can be inmediately enqued or enabled/disabled on demand. .
