# BAU tasks


### Rerunning the audit sheet population task

If there was an error during the `AddAuditDataToSpreadsheetJob` then the
spreadsheet may not have been populated fully.

Once the cause of the error has been corrected you can safely either wait for
the next nightly run of the task or manually re-run the task. NB: the task will
run at its scheduled time even if you manually re-ran the task.

To re-run the job, log into the AWS console, and run a new task for the
[tvs2_production_web_update_spreadsheets_task task][task_link].

Set the Launch type to `EC2` and cluster to `tvs-cluster-production` and click the
`Run Task` button.

The audit sheet will take around 5 minutes to update once the task has been started.

You can also check Papertrail by searching for "AddAuditDataToSpreadsheetJob".

[task_link]: https://eu-west-2.console.aws.amazon.com/ecs/home?region=eu-west-2#/taskDefinitions/tvs2_production_web_update_spreadsheets_task/status/ACTIVE

### Fixing the "Permission denied. Failed to verify the URL ownership." error

1. Visit [webmaster_central] and login using the "teachingjobs@digital.education.gov.uk" account details
from the secrets repo.

2. Click add an owner for: "analytics-prod@teacher-vacancy-service.iam.gserviceaccount.com"

[webmaster_central]: https://www.google.com/webmasters/verification/details?hl=en&siteUrl=https://teaching-vacancies.service.gov.uk/&authuser=3&mesd=ACQ0Nr_qx9U2vbqOrgcxCOE4aFyfB_GW-g6bpYPCnkxgHBU_6VaQ_VuatrdgmiW5ABZQMpTHrtERgmvhOB04uji-_nAlH6WkBSaMlpKO2Jk5N1VU7L8DcIJHvokNamPH2rmTcnvHuK6mGBWYiMT35ED0FjbrgZHFrWwFgjpAVvnhaKAtoEmVL25dnyo2XQt05pJe1yN7guWswWfafEYIGoe5Q-k4WNsJtQ
