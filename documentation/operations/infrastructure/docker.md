# Docker

## Containers vs Images

It's worth a quick reminder that Containers are created from Images. [Docker's own documentation says](https://www.docker.com/resources/what-container)
> A Docker container image is a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings.
> Container images become containers at runtime and in the case of Docker containers - images become containers when they run on Docker Engine.

## A multi-stage [Dockerfile](../Dockerfile)

- We use multi-stage builds to create significantly smaller images.
- Docker's [blog entry on multistage builds](https://www.docker.com/blog/advanced-dockerfiles-faster-builds-and-smaller-images-using-buildkit-and-multistage-builds/) helpfully starts:
> Multistage builds added a couple of new syntax concepts.
>
> First of all, you can name a stage that starts with a `FROM` command with `AS stagename` and use `--from=stagename` option in a `COPY` command to copy files from that stage.
- Images created from the `builder` stage are ~357 MB in size
- Images created from the `production` stage are ~83 MB in size
- The (Docker) production _stage_ should not be confused with the (AKS) production _environment_

For both stages, we:

- use the [official Docker Ruby image](https://hub.docker.com/_/ruby), based off [Alpine Linux](https://alpinelinux.org/)
- use the tag corresponding to the specific version of Ruby, but not of Alpine e.g. `ruby:2.7.2-alpine`, rather than `ruby:2.7.2-alpine3.13`
- use the [apk tool](https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management) to update and install packages
- set the timezone to `Europe/London` for consistency in logs
- set the working directory to `/app`

Steps from the `builder` stage worth highlighting:

```
FROM ruby:2.7.2-alpine AS builder

COPY Gemfile* ./
RUN bundle install --no-binstubs --retry=5 --jobs=4 --no-cache --without development test

COPY package.json yarn.lock ./
RUN yarn install --check-files

COPY . .

RUN RAILS_ENV=production bundle exec rake assets:precompile
```

- Name the stage `builder` so that it can be built individually, and allow copying of files to the `production` stage
- Run a Ruby bundle command, excluding `development` and `test` dependencies
- Copy any remaining files in the repo that were excluded by the [.dockerignore](../.dockerignore) file
- Precompile application frontend assets

Steps from the `production` stage worth highlighting:

```
FROM ruby:2.7.2-alpine AS production
COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

EXPOSE 3000
CMD bundle exec rails db:migrate:ignore_concurrent_migration_exceptions && bundle exec rails s
```

- Name the stage `production` so that it can be built individually
- Copy from the `builder` stage:
    - `/app`
    - `/usr/local/bundle/`
- Listen on port 3000
- Run two Ruby bundle commands:
    - `bundle exec rails db:migrate:ignore_concurrent_migration_exceptions`
    - `bundle exec rails s`

## Build a Docker image

### Building with `docker` commands

Although it's possible to build a Docker image by typing `docker` commands into a terminal, most images for teaching vacancies are built by a [GitHub Actions workflow](../.github/workflows/deploy.yml)

### Building with GitHub Actions workflow

- `docker/setup-buildx-action@v1`
    - Use the Docker Buildx CLI plugin
- `docker/login-action@v1`
    - Log in to Docker Hub with username/password stored in GitHub Secrets
- `docker/build-push-action@v2`
    - Pull the image tagged `builder-main`
    - Check if there's an image tagged `builder-BRANCHNAME`
    - Use the build argument `BUILDKIT_INLINE_CACHE=1` to include cache metadata
    - Build an image from Docker target `builder` defined in the Dockerfile
    - Tag it with `builder-BRANCHNAME`
    - Push the image to the Docker Hub repository
- `docker/build-push-action@v2`
    - Use the image tagged `builder-main` (already cached locally in the step above)
    - Use the image tagged `builder-BRANCHNAME` (already created locally in the step above)
    - Check if there's an image tagged `BRANCHNAME`
    - Use the build argument `BUILDKIT_INLINE_CACHE=1` to include cache metadata
    - Build an image from Docker target `production` defined in the Dockerfile
    - Tag the image with `BRANCHNAME`
    - Tag the image with `TAG`
    - Push the image to the Docker Hub repository

### Building with Makefile

The [Makefile](../Makefile) in the root of the project supports building a Docker image from local code.

Issuing the command `make build-local-image` executes the following commands:

```
.PHONY: build-local-image
build-local-image:
		$(eval export DOCKER_BUILDKIT=1)
		$(eval branch=$(shell git rev-parse --abbrev-ref HEAD))
		$(eval tag=dev-$(shell git rev-parse HEAD)-$(shell date '+%Y%m%d%H%M%S'))
		docker build \
			--build-arg BUILDKIT_INLINE_CACHE=1 \
			--cache-from $(repository):builder-main \
			--cache-from $(repository):builder-$(branch) \
			--cache-from $(repository):main \
			--cache-from $(repository):$(branch) \
			--cache-from $(repository):$(tag) \
			--tag $(repository):$(branch) \
			--tag $(repository):$(tag) \
			--target production \
			.

		docker push $(repository):$(branch)
		docker push $(repository):$(tag)
```

- Enable BuildKit by setting an environment variable
- Use `git` to determine the branch name (`dev`, `staging`, `main`, or a feature branch)
- Create a unique tag comprised of the branch name plus a timestamp
- Use the image tagged `builder-main` (already cached locally in the step above)
- Use the image tagged `builder-BRANCHNAME` (already created locally in the step above)
- Use the image tagged `main`
- Use the image tagged `BRANCHNAME` (potentially cached locally from a previous run)
- Use the build argument `BUILDKIT_INLINE_CACHE=1` to include cache metadata
- Build an image from Docker target `production` defined in the Dockerfile
- Tag it with `BRANCHNAME`
- Tag it with `TAG`
- Push the image to the Docker Hub repository, with both tags

## Run a Docker container on Azure AKS

The GitHub Action workflow [build_and_deploy.yml](../.github/workflows/build_and_deploy.yml):
- builds and tags a Docker image
- pushes the Docker image to the Docker Hub repository
- sets the Terraform variable `app_docker_image` to the image tag
- uses `terraform apply` to update the `staging` environment to use a container based off the tagged image
- runs a smoke test to check the recent update has not broken the `staging` environment
- uses `terraform apply` to update the `production` environment to use a container based off the tagged image

## Verify what's in a Docker image

### Locally

- Go to the tags view of the [dfedigital/teaching-vacancies](https://hub.docker.com/r/dfedigital/teaching-vacancies/tags) repository
- Copy a tag

```
dfedigital/teaching-vacancies:review-pr-2100-fa6128324de4bbf0d8f238011e672f5c06b9c975-20201008150346
```

Pull the image and a new container based off it by issuing the command

```
docker run -it --rm dfedigital/teaching-vacancies:review-pr-2100-fa6128324de4bbf0d8f238011e672f5c06b9c975-20201008150346 /bin/sh
```

This passes the options:

- `-it` - a combination of `-i` and `-t` which is
    `--interactive` ("Keep STDIN open even if not attached")
    `--tty` ("Allocate a pseudo-TTY")
- `--rm` - tells the Docker engine to remove the container (but not the image) when it exits
- `/bin/sh` - starts a shell (as the image is based off Alpine Linux, you'll get an error if you try to start `/bin/bash`)

At this point you'll be in the `/app` directory

## Advanced features

### BuildKit builds

- [BuildKit](https://docs.docker.com/develop/develop-images/build_enhancements/) was introduced in Docker 18.09
- Enabling BuildKit sped up builds by at least a minute

### Buildx

- [Buildx](https://docs.docker.com/buildx/working-with-buildx/) was introduced in Docker 19.03
- This is a requirement for `v2` and newer versions of the GitHub Action [docker/build-push-action](https://github.com/docker/build-push-action)

### Caching

- Pulling an image, or image layer, from the Docker Hub repository is typically much less "expensive" in time than building from source
- We cache images for the `builder` and `production` targets, across all branches

### `Builder` stage image tags

- `builder-dev`
- `builder-staging`
- `builder-main`

And for feature branches, these may undergo several pushes to the branch, so it's worth storing the builder image, to speed up subsequent builds, e.g.

- `builder-TEVA-1296-alert-filters`

### `Production` stage image branch tags

- `dev`
- `staging`
- `main`

And for feature branches:

- `TEVA-1296-alert-filters`

The image tied to these tags changes frequently, with each build, for caching.

Do NOT use these tags to generate containers - instead, choose a unique tag listed below

### `Production` stage image unique tags

For images built off the `main` branch, we use the [SHA of the GitHub commit](https://docs.github.com/en/free-pro-team@latest/actions/reference/context-and-expression-syntax-for-github-actions), e.g.

[Docker image tagged `a18165a5a6d8ae5b753ac7c3cac65f0cbc34dd18`](https://hub.docker.com/layers/dfedigital/teaching-vacancies/a18165a5a6d8ae5b753ac7c3cac65f0cbc34dd18/images/sha256-7ae9ec3802192d41dc9846db734303efecc372d90d11317864f2cc0478908bf5?context=explore) comes from [GitHub commit `a18165a5a6d8ae5b753ac7c3cac65f0cbc34dd18`](https://github.com/DFE-Digital/teaching-vacancies/commit/a18165a5a6d8ae5b753ac7c3cac65f0cbc34dd18)


### Multi-stage builds

- [Multi-stage builds](https://docs.docker.com/develop/develop-images/multistage-build/) were introduced in Docker 17.05

## GitHub Packages (Container registry)

### GitHub container registry

The Docker images for Teaching Vacancies are stored in the GitHub's container registry [https://github.com/DFE-Digital/teaching-vacancies/](https://github.com/DFE-Digital/teaching-vacancies/pkgs/container/teaching-vacancies).

### GitHub authentication
Access and authentication to GitHub is via the default
[GITHUB_TOKEN](https://github.com/DFE-Digital/teaching-vacancies/blob/main/.github/workflows/build_and_deploy.yml#L105). Follow link for further info about [authentication in github](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry#authenticating-in-a-github-actions-workflow)

An example of authentication via Github token is as below

```
  - name: Login to GitHub Container Registry
    uses: docker/login-action@v3
    with:
        registry: ghcr.io
        username: ${{ github.repository_owner }}
        password: ${{ secrets.GITHUB_TOKEN }}
```

### GitHub container registry

Docker images are pushed to Github container registry through the `docker push` command. A single Github container registry can hold many Docker images (stored as *tags*).

To view the docker images stored on GitHub's container registry, you need to go through DfE's main GitHub page, and then click packages. Please note, GitHub repositories are different from GitHub packages:
- [Teaching-vacancies Packages (docker images)](https://github.com/DFE-Digital/teaching-vacancies/pkgs/container/teaching-vacancies)

### Docker image scan

As part of the CI/CD, we conduct a Docker security scan using `snyk`, by invoking Snyk's docker image: `snyk/snyk-cli:docker`. This allows us a deep image inspection and vulnerability scan. When a vulnerability is detected while scanning, this breaks breaks CI/CD build. The vulnerability detected by `snyk`would need to be fixed before a successfully build can be completed.

To fix it:
1. Identify the offending package in the CI error message.
2. Search for a patched non-vulnerable version.
3. Set the explicit non-vulnerable version dependency (EG: `openssl=3.1.8-r0`) in the [Dockerfile's](/Dockerfile) `PROD_PACKAGES` list.
4. Test the fix by pushing the Dockerfile change into a review app, an check the build output.
5. Review & merge if it fixed the build.
