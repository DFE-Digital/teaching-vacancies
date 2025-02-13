# Devcontainer

## Why use devcontainers?

Devcontainers provide completely isolated environments for development on a specific project. Read
more about our motivations in the [ADR](adr/0011_use_devcontainers.md).

## How it works

See [Developing inside a Container](https://code.visualstudio.com/docs/remote/containers) in the VS
Code documentation.

## Container setup script and environment

After building the container, a [custom `postCreate` script](../.devcontainer/post_create.sh) is
executed against it for initial setup (installing dependencies, creating and seeding the database,
and setting up the environment).

## Working in the container

### Running things

The container includes a very basic bootstrap `bashrc` which adds the Rails `bin/` directory (for
binstubs for `rails`, `rspec`, etc.) as well as Bundler's bin directory to the `PATH`.

For performance reasons, we recommend you use the binstubs over `bundle exec [command]` for those
commands that have a binstub.

### System tests

System tests with `js: true` are run on a "standalone" (no hub) Selenium Chrome container. If you
want to watch the tests as they happen, a web VNC viewer is exposed by that container on port
7900, which is published to the host: http://localhost:7900

### Personal dotfiles

Make your devcontainer feel like home by setting up your dotfiles inside the container using VS
Code:

- Make sure your dotfiles are sufficiently Debian-friendly (e.g. don't rely on things that only
  work on other Linux distributions or macOS)
- Have an install script to get things bootstrapped (with one of the default names, or you can
  specify a manual installation command)
  - Pro tip: You can also use this install script/command to install custom software, e.g. if
    you use a dotfiles manager like [rcm](https://github.com/thoughtbot/rcm).

Configure your VS Code as follows:

```json
{
  "dotfiles.repository": "my_github_username/my_repo_name",
  "dotfiles.installCommand": "path_to_script.sh" // Optional
}
```

## Optional advanced setup

### Using a volume as workspace root

At their core, containers are a Linux technology - running them on macOS or Windows requires an
intermediate virtual machine. A significant area of performance overhead with this arrangement is
IO between the host and the container, which means that having your workspace bind mounted into
the container makes everything run slower than if you ran it straight on the host.

When used by non-developers, that performance hit is acceptable given all the other benefits
devcontainers bring. If you want to e.g. frequently run RSpec though, or have a slightly slower
machine and see multi-second page load times, you may want to consider using a volume for the root
of your workspace, instead of bind mounting a host folder into the container.

This provides near-native performance, but there are two minor downsides to the workspace living
in a volume:
- You cannot easily interact with the filesystem in the volume from your host OS anymore
- You run the risk of losing changes if you e.g. accidentally delete the volume (make sure to
  frequently push your changes to Github)

The simplest way to do so is:
- Before you start, ensure you have committed and pushed all your changes as you'll start from a
  fresh checkout of the repository
- From the VS Code Command Palette (`Cmd-Shift-P` or `Ctrl-Shift-P`), choose "Remote-Containers:
  Clone repository in Container Volume"
- Choose "Github", then find this repository in the dropdown (`DFE-Digital/teaching-vacancies`)
- Wait while the container rebuilds
- VS Code will have checked out the repository using HTTPS, replace `origin` with a Git-over-SSH
  URL:
  ```
  git remote rm origin
  git remote add origin git@github.com:DFE-Digital/teaching-vacancies.git
  ```
- Reminder: You will need to create a `.env` file in the new volume-based workspace again

> ⚠️ **Gotcha:** If you get a Docker error "`Mounts denied: The path /workspaces/teaching-vacancies
> is not shared from the host and is not known to Docker.`", you may be experiencing the following
> issue: https://github.com/microsoft/vscode-remote-release/issues/5388
>
> Until this is fixed, you can work around this by adding `/workspaces` under `Preferences >
> Resources > File Sharing` in Docker Desktop.



More details: https://code.visualstudio.com/remote/advancedcontainers/improve-performance

## Gotchas

### Published Rails server ports
In order for our devcontainer setup to be easily usable for developers who prefer a different
workflow from the default VS Code devcontainer integration, we publish Rails's port 3000 in the
`docker-compose.yml`. This takes precedence over the VS Code devcontainer port forwarding using
`forwardPorts` in `devcontainer.json` and makes requests appear to Rails to come from the network
(rather than being local requests). This means you always need to allow the Rails server to bind to
`0.0.0.0` when running `rails s` manually.
