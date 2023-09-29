# Azure Kubernetes Service (AKS)

Teaching Vacancies is hosted on [Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/).

## AKS Structure for Teaching Vacancies
Teaching Vacancies service environments use 2 AKS clusters:

| Cluster    | Name                                   |
|------------|----------------------------------------|
| Test       | s189-teacher-services-cloud-test       |
| Production | s189-teacher-services-cloud-production |

### Test cluster environments
| Namespace      | Environments            |
|----------------|-------------------------|
| tv-development | **Review Apps**, **QA** |
| tv-staging     | **Staging**             |
### Production cluster environments
| Namespace     | Environments   |
|---------------|----------------|
| tv-production | **Production** |
## Installing the Azure Client and Kubectl
1. Install the [Azure Client](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
2. Install `kubectl`
    ```
    az aks install-cli
    ```

## Accessing AKS Test cluster

1. Activate your access for our Test cluster (`s189-teacher-services-cloud-test`) through [Azure Privileged Identity Management (PIM) request](https://technical-guidance.education.gov.uk/infrastructure/hosting/azure-cip/#privileged-identity-management-pim-requests) in the [Azure Portal](https://portal.azure.com.mcas.ms/).

2. Login into the testing tenant using the Azure Cli. This will launch your browser for the login.

    ```
    az login --tenant 9c7d9dd3-840c-4b3f-818e-552865082e16
    ```

3. From Teaching Vacancies root directory, get the credentials for cluster.

    ```
    make test-cluster get-cluster-credentials
    ```
Once you have the correct credentials, you can execute `kubectl` commands over the authenticated cluster.

## Accessing/Executing commands over our services

### The short way
We have added a series of [Makefile](/Makefile) definitions to speed up common Rails developer commands over any of our environments:

If the environment has multiple pods running the web/application. The command will be executed over the first listed pod.
#### Opening a Rails Console
```
make review pr_id=5432 railsc
make qa/staging/production railsc
```

#### Opening a shell
```
make review pr_id=5432 shell
make qa/staging/production shell
```

#### Running a rake task
```
make review pr_id=5432 rake task=audit:email_addresses
make qa/staging/production rake task=audit:email_addresses
```

#### Tailing application logs
```
make qa logs
make review pr_id=5432 logs
```

### The kubectl way

#### To list the deployments (apps) in the cluster:
```
kubectl -n tv-development get deployments
```

#### To list the application pods (running instances) in the cluster:

```
kubectl -n tv-development get pods
```

#### Opening a console in a Review App

To open a console for an app deployment (on its first pod):

```
kubectl -n tv-development exec -ti deployment/teaching-vacancies-review-pr-xxxx -- /bin/sh
```

To open a console in the particular pod:

```
kubectl -n tv-development exec -ti teaching-vacancies-review-pr-xxxx-podid -- /bin/sh
```

#### Executing commands in a Review App

```
kubectl -n tv-development exec deployment/teaching-vacancies-review-pr-xxxx -- ps aux
```

## Other documentation

- [Infra Team Developer onboarding into AKS](https://github.com/DFE-Digital/teacher-services-cloud/blob/main/documentation/developer-onboarding.md#developer-onboarding). This has extended info on our AKS setup and commands.
- [Azure AKS Client reference](https://learn.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest)
