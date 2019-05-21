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
