# Hosting

Teaching Vacancies is hosted on [Azure Cloud Infrastructure Platform (CIP)](https://technical-guidance.education.gov.uk/infrastructure/hosting/azure-cip/), with the services running as an [Azure Kubernetes Service](https://learn.microsoft.com/en-us/azure/aks/).

## Environments

| Environment | URL                                                                                                    | Code branch | CI/CD workflow      | AKS Cluster             | AKS Namespace |
| ----------- | ------------------------------------------------------------------------------------------------------ | ----------- | ------------------- | ----------------------------- | ------------------- |
| Production  | [https://teaching-vacancies.service.gov.uk](https://teaching-vacancies.service.gov.uk)                 | `main`      | [build_and_deploy.yml](../.github/workflows/build_and_deploy.yml) | s189-teacher-services-cloud-production | tv-production
| Staging     | [https://staging.teaching-vacancies.service.gov.uk](https://staging.teaching-vacancies.service.gov.uk) | `main`      | [build_and_deploy.yml](../.github/workflows/build_and_deploy.yml) | s189-teacher-services-cloud-test    | tv-staging
| QA          | [https://qa.teaching-vacancies.service.gov.uk](https://qa.teaching-vacancies.service.gov.uk)           | `main`      | [build_and_deploy.yml](../.github/workflows/build_and_deploy.yml) | s189-teacher-services-cloud-test        | tv-development
| Review      | `https://teaching-vacancies-review-pr-xxxx.test.teacherservices.cloud`                                 | multiple    | [build_and_deploy.yml](../.github/workflows/build_and_deploy.yml) | s189-teacher-services-cloud-test        | tv-development

Ephemeral review apps that are created when a PR is created on GitHub, and destroyed when the PR is merged. These have URLs which contain the Pull Request number, like `https://teaching-vacancies-review-pr-6441.test.teacherservices.cloud`

The QA and Staging environments have [integration with DSI](./dsi-integration.md).

The Staging environment is a pre-production environment, to identify issues with code before it's promoted to Production.
On merging a Pull Request, the same code is deployed first to Staging, and after a successful smoke test, to Production.

QA environment contains the same code branch as Staging and Production environments, and is used by multiple members of the team for general testing about a production-like environment.

## Deployments
Detailed information about our deployment process in [this link](./deployments.md).

## Azure Kubernetes Service (AKS) organisation and permission model

Teaching Vacancies members have access to three different Azure Subscriptions. Each subscription gives access to a [Kubernetes cluster](https://learn.microsoft.com/en-us/azure/aks/concepts-clusters-workloads#kubernetes-cluster-architecture) with the same name.

Each of the Kubernetes clusters is divided into [namespaces](https://learn.microsoft.com/en-us/azure/aks/concepts-clusters-workloads#namespaces).

Each namespace hosts one/multiple different environments for Teaching Vacancies service.

| Cluster     | Name                                    | DfE Platform Identity Group | Access                                                  |
|-------------|-----------------------------------------|-----------------------------|---------------------------------------------------------|
| Development | s189-teacher-services-cloud-development | s189 TV delivery team       | Permanently granted                                     |
| Test        | s189-teacher-services-cloud-test        | s189 AKS admin test PIM     | Permanently granted                                     |
| Production  | s189-teacher-services-cloud-production  | s189 TV production PIM      | Up to 8 hours. Needs [team member approval](https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/ResourceMenuBlade/~/MyActions/resourceId/73b976f6-fd4c-461f-bacb-95c6fae6f9d0/resourceType/Security/provider/aadgroup/resourceDisplayName/s189%20TV%20production%20PIM/resourceExternalId/73b976f6-fd4c-461f-bacb-95c6fae6f9d0) |

Teaching Vacancies application environments are hosted in the following clusters/namespaces:

| App environment | Kubernetes Cluster                     | Kubernetes Namespace |
|-----------------|----------------------------------------|----------------------|
| Review          | s189-teacher-services-cloud-test       | tv-development       |
| QA              | s189-teacher-services-cloud-test       | tv-development       |
| Staging         | s189-teacher-services-cloud-test       | tv-staging           |
| Production      | s189-teacher-services-cloud-production | tv-production        |


During [onboarding](./onboarding.md) you will have been granted access to selected Azure resources and roles.

By default, you will have access to TV Kubernetes namespaces/envs/apps hosted in the `s189-teacher-services-cloud-test` cluster.

For the `tv-production` namespace containing the Production environment running the Teaching Vacancies live app, you will have to [request the temporal activation](https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/ResourceMenuBlade/~/MyActions/resourceId/73b976f6-fd4c-461f-bacb-95c6fae6f9d0/resourceType/Security/provider/aadgroup/resourceDisplayName/s189%20TV%20production%20PIM/resourceExternalId/73b976f6-fd4c-461f-bacb-95c6fae6f9d0) (up to 8 hours per request) for the `Member` role on the (`s189 TV production PIM`).

Senior developers/tech lead on the team and DevOps have the will be able to [approve each others requests](https://portal.azure.com/#view/Microsoft_Azure_PIMCommon/ResourceMenuBlade/~/ApproveRequests/resourceId/73b976f6-fd4c-461f-bacb-95c6fae6f9d0/resourceType/Security/provider/aadgroup/resourceDisplayName/s189%20TV%20production%20PIM/resourceExternalId/73b976f6-fd4c-461f-bacb-95c6fae6f9d0).

Users aren´t able to self-approve their own role requests.

## Getting Production access on Azure Platform
1. Request your access for the `s189 TV production PIM` role on the [Azure Privileged Identity Management (PIM) request](https://technical-guidance.education.gov.uk/infrastructure/hosting/azure-cip/#privileged-identity-management-pim-requests) under `Groups` tab in the [Azure Portal](https://portal.azure.com.mcas.ms/).
2. The request will need to be approved.

## Installing the Azure Client and Kubectl
1. Install the [Azure Client](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
2. Install `kubectl`
    ```
    az aks install-cli
    ```

## Login from Azure Console
- You will need [production access](#getting-production-access-on-azure-platform) first if you want to run commands on the production environment.
- Log into the tenant using the Azure Cli. This will launch your browser for the login.
    ```
    az login --tenant 9c7d9dd3-840c-4b3f-818e-552865082e16
    ```
- [OPTIONAL] From Teaching Vacancies root directory, get the credentials for the environment.
    - Only needed if you're going to execute `kubectl` commands directly. `make env command` shortcuts in our makefile will execute this step automatically.
    - For `test` cluster environments (`review`, `qa`, `staging`):
      ```
      make qa get-cluster-credentials
      ```
    - For `production` environment:
      ```
      make production get-cluster-credentials CONFIRM_PRODUCTION=YES
      ```

## Makefile shortcuts for kubernetes commands

We have added a series of [Makefile](/Makefile) definitions to speed up common Rails developer commands over any of our environments:

If the environment has multiple pods running the web/application. The command will be executed over the first listed pod.

### Opening a Rails Console
```
make review pr_id=5432 railsc
```
```
make qa/staging railsc
```
```
make production railsc CONFIRM_PRODUCTION=YES
```

### Opening a shell
```
make review pr_id=5432 shell
```
```
make qa/staging shell
```
```
make production shell CONFIRM_PRODUCTION=YES
```

### Running a rake task
```
make review pr_id=5432 rake task=audit:email_addresses
```
```
make qa/staging rake task=audit:email_addresses
```
```
make production rake task=audit:email_addresses CONFIRM_PRODUCTION=YES
```

### Tailing application logs
```
make review pr_id=5432 logs
```
```
make qa/staging logs
```
```
make production logs CONFIRM_PRODUCTION=YES
```

## Kubernetes commands
Executing commands with `kubectl` tool.

### Listing the deployments (apps) in the cluster:
```
kubectl -n tv-development get deployments
```

### Listing the application pods (running instances) in the cluster:

```
kubectl -n tv-development get pods
```

### Opening a console in a Review App

To open a console for an app deployment (on its first pod):

```
kubectl -n tv-development exec -ti deployment/teaching-vacancies-review-pr-xxxx -- /bin/sh
```

To open a console in the particular pod:

```
kubectl -n tv-development exec -ti teaching-vacancies-review-pr-xxxx-podid -- /bin/sh
```

### Executing commands in a Review App

```
kubectl -n tv-development exec deployment/teaching-vacancies-review-pr-xxxx -- ps aux
```

## Set up a new environment
- Create file `terraform/workspace-variables/<env>.tfvars.json`
- Create file `terraform/workspace-variables/<env>_app_env.yml`
- Create SSM parameters of type `SecureString`:
  - `/teaching-vacancies/<env>/app/BIG_QUERY_API_JSON_KEY`
  - `/teaching-vacancies/<env>/app/GOOGLE_API_JSON_KEY`
  - `/teaching-vacancies/<env>/app/secrets`
  - `/teaching-vacancies/<env>/infra/secrets`
- Add a target to the Makefile
```
.PHONY: <env>
<env>: ## <env>
		$(eval env=<env>)
		$(eval var_file=<env>)
```
- Run:
  ```shell
  make passcode=MyPasscode tag=47fd1475376bbfa16a773693133569b794408995 <env> terraform-app-apply
  ```
- If you want to have a deployment triggered by a push to a branch, add a trigger to [build_and_deploy.yml](../.github/workflows/build_and_deploy.yml)
```
on:
  push:
    branches:
      - dev
      - <env>
```
- Optionally, [refresh the database](database-backups.md) with a sanitised copy of the production data



## Other documentation

- [Infra Team Developer onboarding into AKS](https://github.com/DFE-Digital/teacher-services-cloud/blob/main/documentation/developer-onboarding.md#developer-onboarding). This has extended info on our AKS setup and commands.
- [Azure AKS Client reference](https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest)
