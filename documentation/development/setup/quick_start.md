# Developers quick start

This project uses [devcontainers](https://code.visualstudio.com/docs/remote/create-dev-container)
to provide a seamless onboarding experience for developers and other team members.

You will need the following software installed on your system:
- [Git](https://github.com/git-guides/install-git)
- [Docker Desktop](https://www.docker.com/get-started)
  - You will need to start Docker before the process will work.
- [Visual Studio Code](https://code.visualstudio.com)

To get the application running:
- Clone the repository to a folder of your choice
- Ask another developer for a `.env` file, and place it in the root of the application folder
  (you can set up your AWS access to be able to do this yourself later)
- Open the folder in VS Code, and when prompted, choose "Reopen in container"
- The container will now build and execute first run tasks - this will take between 5 and 10 minutes
  depending on the performance of your computer. Wait for the terminal showing build tasks to
  display "`Done. Press any key to close the terminal.`"

When the build has finished, you can run the application by clicking on "▶️ Start app" in the status
bar, using the VS Code "Run task" option, or the Rails convention `bin/dev` script. This will start:
- The Rails application running on http://localhost:3000
- An asset build task each for Javascript and CSS
- Sidekiq for processing background jobs

<details>
  <summary>Optional: Advanced custom setup (for developers)</summary>

  > The Docker-based devcontainer setup (see [configuration](.devcontainer)) is our "gold standard"
  > reference implementation of a local development environment. We highly recommend you use it, but
  > you're of course free to work in whatever way makes you the most happy and productive.
  >
  > This might involve running a container-based workflow using vanilla `docker-compose` (working
  > inside the container using a command-line text editor, or outside the container in a GUI editor
  > or IDE), running a Linux VM with a container engine for that extra bit of performance, or just
  > using the container definitions as a guide to setting the app up locally without any Docker
  > involvement at all.
  >
  > Following convention, a `bin/dev` script is provided that uses Foreman to run all the tasks
  > needed for the application.
</details>

---

## Additional setup

This section describes optional additional setup tasks once you have the application up and running.
It is mainly relevant for developers and not strictly necessary to run the application.

### AWS credentials, MFA, and role profiles

Once onboarded to AWS, you should finish setting up your account by following the steps described in
the [AWS roles and CLI tools documentation](/documentation/operations/infrastructure/aws-roles-and-cli-tools.md).

### Environment Variables

Some environment variables are stored in [AWS Systems Manager Parameter Store](https://eu-west-2.console.aws.amazon.com/systems-manager/parameters/?region=eu-west-2&tab=Table), some are stored in the repository.

Secrets (eg: API keys) are stored in AWS Systems Manager Parameter Store in `/teaching-vacancies/<env>/app/*` and `/teaching-vacancies/<env>/infra/*` files.

Non-secrets (eg: public URLs or feature flags) are stored in the repository in `terraform/workspace-variables/<env>_app_env.yml` files.

Run the following command to fetch all the required environment variables for development and output to a shell environment file:

```
aws-vault exec ReadOnly -- make -s local print-env > .env
```

[Git secrets](/documentation/development/tooling/secrets-detection.md) offers an easy way to defend against accidentally publishing these secrets.
