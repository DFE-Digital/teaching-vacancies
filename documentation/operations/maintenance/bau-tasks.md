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
