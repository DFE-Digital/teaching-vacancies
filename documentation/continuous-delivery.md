# Continuous delivery

## Requirements
We want to deliver new features to production in the most efficient manner for the business. It should meet these requirements:

### Automation
Deployment is a repeatable task and as such it can be 100% automated. This frees up time for developers to spend their time creating features, bringing value to the business.

### Visibility
The process may be automated but the business still needs to review new features so they can approve the change or ask for adjustments.

We also want visibility of the deployment process itself so we know:
* which version is being deployed onto which stage at any time
* if the deployment was successful
* if the deployment failed and why

### Reliability
The live website should always be up and running and should never show errors to the users. Since we want the deployment process to be automated, we must add controls to give us confidence that nothing will break. They should be implemented at different steps in the pipeline: before, during and even after deployment. The earlier the better.

Tests should allow testing a new feature in isolation, but also in integration with other features or different dataset.

Some tests should validate the application logic in isolation. Others should validate the application in a production-like environment to iron out issues with the environment.

When the code is pushed to production, there should be zero downtime and it should be transparent to end users.

Monitoring should run continuously to check the production application.

### Repeatability
The artifact created in the workflow should be deployed to a test environment and tested. The exact same artifact should be deployed to the production environment. In case of an issue, we would know it's not due to the build process. Also, the same artifact can be deployed to a dev environment to try to reproduce the issue.

### Velocity
The real test for a new feature is when it's in the hand of real users. It should take the minimum amount of time to be deployed to production. This shortens the feedback loop so the business can see the change and ask for adjustments quickly if necessary.

Developers look after the deployment to make sure a new feature is delivered to production successfully. Reducing the deployment time means they spend less time looking at it and it reduces their mental workload.

If the time to release is slow, then developers may be tempted to batch several features into one big change, which increases the risk of failure and makes rollbacks harder. If it's fast, we can push lots of small changes, which decreases the risk and helps the business to iterate quickly.

### Self-service
The developers should feel empowered to propose, test or deploy changes. Dependencies on external teams should be minimal, for example asking for permission to deploy. And dependencies on other team members as well, for example when resources are shared and developers have to wait for the resource to be free.

## Solution

Deployments are fully automated using [Github actions](https://docs.github.com/en/free-pro-team@latest/actions). When a pull request is merged, it triggers build, tests and deployment to different environments, up to the live environment, without any human intervention.

Our [Github actions dashboard](https://github.com/DFE-Digital/teaching-vacancies/actions) shows the current status of the workflows. Updates are pushed to slack in the `#twd_tv_dev` channel.

When a developer creates a pull request, a dedicated `review app` is automatically created for them and populated with test data. It allows them to test the new feature in isolation and show it to the business for validation.

They can also deploy manually to the `dev` permanent environment. This allows integrating different branches or using specific `dev` data. They can build and deploy directly from their development environment. They can also push their changes to the `dev` branch, which will trigger a deployment to the dev environment.

Unit tests are run by the developers manually and by the automated workflow when they push a branch.

When a pull request is merged to the master branch, a docker image is built and stored on [Docker hub](https://hub.docker.com/r/dfedigital/teaching-vacancies). This is the build artifact that will be deployed to all environments.

The workflow then deploys to the staging environment. Staging has the same configuration as production. We then run a smoke test to validate the application doesn't break in a production-like environment.

If successful, the workflow deploys to the production environment using a "blue-green" technique. This technique makes sure the new app runs successfully before allowing traffic from live user. It also allows a transition with zero downtime for users.

The smoke tests run in production every 5 min to monitor the application and alert us if any issue. StatusCake runs a basic check every minute to alert us quickly in case of a major outage.
