# Cron jobs

## To re-run a specific job:

Go to AWS Console > Services > ECS > Task Definitions.

Select the check-box for the task definition which mentions your intended task and which is prefixed with the correct environment name, for example, tvs2_edge_web_<task_name> (where <task_name> might be, for example, export_tables_as_csv_to_big_query_task).

Select Actions > Run task.

You may see an error in red: “The default capacity provider strategy for the specified cluster does not contain a capacity provider. Update the default capacity provider strategy to associate one or more capacity providers and try again”

In that case, click ‘Switch to launch type’, choose EC2 as the launch type, match the ‘cluster’ environment to the environment of your task (which will be the prefix in its name). Finally click ‘Run task’ (a button hidden in the bottom right corner of the page).

## To see the live logs

You can copy the task id (after going through the process described under 'To re-run a specific job') and search for it in Papertrail.

If a job is failing, you may want to ssh into the container. This is documented [here](https://github.com/DFE-Digital/teaching-vacancies-service-secrets/tree/master/secrets/ssh), but you will need the public IP address of the EC2 container. To get this information, go to AWS Console > Services > EC2 (not ECS!) > Instances. Select the checkbox for any instance which is both running and has the correct environment in its name. The public IP is then listed as IPv4 Public IP in the Description. (If this IP address doesn’t work - the ssh command to connect might hang at ‘Connecting to port’ - try a different instance which is both running and has the correct environment in its name.)
If you are not on Gov-WiFi (e.g. working from home), you will need to add an inbound rule to mark your IP as safe. On the left-hand bar, go to Network & Security > Security Groups. Select the intended instance, click Actions > Edit inbound rules > Add Rule. The type will be SSH and the Source will be My IP. You can google your IP and copy and paste it in. Finally, click Save.
