# Encourage use of devcontainers for local development

**Date: 2021-09-22**

## Status

**Decided**

## Context and Problem Statement

Setting up the Teaching Vacancies app for local development is a frustrating process involving many
steps and multiple dependencies driven by manually updated setup documentation. A workflow based on
[devcontainers](https://code.visualstudio.com/docs/remote/create-dev-container) would alleviate
much of this setup pain, and provide a trivially reproducible environment for local development,
benefitting both developers and non-developers on the team.

## Decision Drivers

- Complex and time-consuming onboarding and "re-boarding" experience of the application
- Difficulties experiences by non-developers in getting the app set up locally, and getting it
  running again after major dependency changes (e.g. our recent addition of PostGIS)
- Increasing adoption of devcontainers as a de-facto standard in the wider development community
  including [Ruby on Rails](https://github.com/rails/rails/tree/main/.devcontainer)
- Possible use of cloud-based development environments such as Github Codespaces in the future to
  enable users on restricted organisation-managed devices to contribute to the application

## Considered Options

- Provide _devcontainer_-based setup for Teaching Vacancies
- Do nothing and continue current local-based workflow

## Decision Outcome

Add devcontainers as an option for now, with a view to iterate on it and improve it to the point
where we can consider it the "official" default way of running Teaching Vacancies (while still
allowing other development workflows for developers who prefer different ways of working).

### Positive Consequences

- Drastically easier onboarding and "re-boarding" (e.g. on a new device or after an OS upgrade
  causing developer tooling issues)
  - Dependencies reduced to just Git, Docker, and VS Code
  - A fully functioning development environment is ready in 10 minutes from scratch, with no user
    interaction beyond opening the repository in VS Code and selecting "Reopen in container"
- Moving entirety of development experience into a container fixes past Docker development workflow
  issues experienced on the team (where tasks and services where executed from the host instead of
  interacting with a shell and an editor from inside the container itself)
- Developers and other team members can develop on any host OS (macOS/Linux/Windows) but we only
  need to support one single consistent environment
  - Does away with all the Mac vs Linux vs WSL setup steps in our current documentation
  - Reduces likelihood of "works on my machine" development environment issues
- "Leave no trace" on the host machine and complete isolation from other projects
  - Removes possibility of "dependency hell" when working on multiple projects
  - Removes need to clutter local environment with applications and dependencies that need to be
    kept up to date and in sync (e.g. Google Chrome and `chromedriver`)
  - Removes need for language version managers (`rbenv`, `nvm`)
- Provides _executable documentation_ of project setup and dependencies
  - Removes need for manually updated setup documentation that can become stale
  - Experienced developers who have a different preferred workflow can get a clear, in-code view
    of setup steps and dependencies
- Good workflow for everyone, but excellent additional integration with Visual Studio Code
  - Automatic passthrough of SSH and GPG keys
  - Language extensions run within the container itself, and can be specified in the devcontainer
    configuration file for instant setup of useful extensions for new users
  - Automatic bootstrapping of personal dotfiles
- Ability to easily move to cloud-based workflows in the future
- Ability to easily propagate new tools and improved configuration to all developers on the team
- Trivial rebuilds to a known good state when performing "dangerous" operations in the container

### Negative Consequences

- Slightly reduced performance on some host OSs (non-Linux) due to Docker being Linux-native
  technology (overhead of containers running in an intermediate VM)
  - Somewhat mitigated by use of volumes for IO-intensive cache directories
  - Can be worked around entirely by moving workspace root into the container, and we will continue
    to investigate before we fully agree on devcontainers as our default workflow
- Container layers need occasional pruning on the host as Docker can fill up disk space quickly
- Some duplication of Docker configuration between production and development configuration (but
  that is to be expected given that use cases are very different)
