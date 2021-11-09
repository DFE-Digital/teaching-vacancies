# Devcontainer

> 🚧 TODO: These notes are a work in progress!

## Quickstart

- Install the following tools:
  - [Docker Desktop](https://www.docker.com/products/docker-desktop)
  - [Git](https://github.com/git-guides/install-git)
  - [Visual Studio Code](https://code.visualstudio.com)
- Clone this repository onto your machine
- Ask a developer for a `.env` file and place it in the repository folder
  - _Optional_: get onboarded on AWS and set up `aws-vault` to fetch dev credentials yourself
- Open the repository in Visual Studio Code and choose "Reopen in container" when prompted
  (in the bottom right corner of the application window)
- Indulge in a caffeinated beverage while the container builds for the first time (5-10 minutes)
- You're ready to go!

## Use without VS Code

_TODO_

## Personal dotfiles

Make sure your dotfiles are sufficiently Debian-friendly, have an `install.sh` script to get things
up and running (you can also use this to install custom packages) and add the following settings
to your VS Code configuration:

```json
{
  "dotfiles.repository": "my_github_username/my_repo_name",
  "dotfiles.installCommand": "path_to_script.sh"
}
```

## Environment

TODO: Explain how `PATH` is set up

## System tests

System tests with `js: true` are run on a "standalone" (no hub) Selenium Chrome container. If you
want to watch the tests as they happen, a web VNC viewer is exposed by that container on port
7900, which is published to the host: http://localhost:7900

## Gotchas

### Published Rails server ports
In order for our devcontainer setup to be easily usable for developers who prefer a different
workflow from the default VS Code devcontainer integration, we publish Rails's port 3000 in the
`docker-compose.yml`. This takes precedence over the VS Code devcontainer port forwarding using
`forwardPorts` in `devcontainer.json` and makes requests appear to Rails to come from the network
(rather than being local requests). This means you always need to allow the Rails server to bind to
`0.0.0.0` when running `rails s` manually.
