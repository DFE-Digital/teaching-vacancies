# Deployment

## Source code

There are currently 4 long standing environments that the team have been using, they each have a purpose but all deployments are managed through Git with webhooks that trigger AWS Codepipeline to fetch the latest code.

| Name           | Purpose                                                             | Tracked Git branch | Deploy mechanism    |
| -------------- | ------------------------------------------------------------------- | ------------------ | -------------       |
| production     | the live service                                                    | master             | pull request        |
| staging        | final quality assurance step and demos                              | develop            | pull request        |
| edge           | devs to test or debug features, code and integrations in isolation  | edge               | force push          |
| testing        | user researchers to conduct usability testing sessions              | testing            | force push          |

- pull request - requires at least 1 peer review
- force push - ask the rest of the team if you can take control of an environment
- testing - is only updated manually by developers on the request of user researchers in order to ensure stability during sessions

## Infrastructure

As we use Terraform to make 95% of our changes to the infrastructure they too should be made in the form of pull requests into the relevant git branch. [You can read about what's not covered in our set up docs](../terraform/README.md).

### Before you start
1. Install the the Terraform client on your machine:
  * [Directly from Hashicorp](https://releases.hashicorp.com/terraform/) (recommended) - select the highest _patch_ for the [_minor_ version we're pinned to](terraform.tf)
  * [Using Brew](https://formulae.brew.sh/formula/terraform) - be mindful that there is no current way to pick what version you have with Brew so this latest version may well put you above [the version we're pinned to](terraform.tf)
2. [Configure AWS on your machine](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html ) so that Terraform has permission to talk to the AWS API
3. Get a local copy of the Terraform variables from the 1Password vault and move them into `/workspace-variables`, eg. `/workspace-variables/edge.tfvars`

### Running a deployment
This is a manual process that we've scripted to help avoid common mistakes. To know when Terraform needs to be deployed, we've included a Terraform option in our pull request templates so it's the responsibility of the author to let the merger know that this step is needed on merge.

This script will change your git branch, do a git pull, change your Terraform environment and load the correct Terraform workspace variables. Getting any one of these wrong can have big implications so if in doubt, ask for a pair and/or help from ops.

#### Step 1
From a local context run the following:
```bash
bin/terraform-deploy testing
```

#### Step 2
Review and approve the changes, it is important to look closely at the changes that are defined as `destroy` to ensure they are what you expect. We pair on all production deployments as this has snuck past us before.
```
Plan: 2 to add, 7 to change, 2 to destroy.

Do you want to perform these actions in workspace "testing"?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: yes
```

#### Step 3
Once the deployment has finished, review the output of the script to ensure everything succeeded by checking AWS to make sure the expected changes were made.


## Upgrading Terraform
We have locked Terraform to its minor version to protect the team from accidentally running a deployment from a version not compatible with the Terraform files we have.

NB. [Terraform is currently releasing 'major' changes in it's next minor version of 0.12](https://www.terraform.io/upgrade-guides/0-12.html) so we have not locked to the traditional major point which might be expected.

Locking will hopefully give us explicit feedback on version issues before being presented with a barrage of Terraform errors throughout all affected files during the last phase of a production deployment.

The intent is for Terraform version upgrades that require changes to be a deliberate action rather than an accident based on an individuals later install of the Terraform client.
