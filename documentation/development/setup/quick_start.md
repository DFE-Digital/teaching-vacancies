# Developers quick start

There are two supported ways to run the application locally. Pick one:

| Setup | What runs where | Good for |
| --- | --- | --- |
| [**Local, with a dockerised database**](#option-1-local-with-a-dockerised-database-recommended) (recommended) | Rails, Node.js and Chrome run on your machine; PostgreSQL/PostGIS runs in Docker | Most developers |
| [**Devcontainer**](#option-2-devcontainer) | Everything runs inside a container, normally opened from VS Code | Onboarding with nothing to install but Docker and VS Code, and non-developers |

Whichever you choose, you will need a `.env` file: ask another developer for one and place it in the
root of the repository (you can set up your AWS access to generate it yourself later, see
[Additional setup](#additional-setup)).

The application is tied to port 3000; no other port will work.

## Option 1: Local, with a dockerised database (recommended)

### Prerequisites

- [Git](https://github.com/git-guides/install-git) and [git-secrets](/documentation/development/tooling/secrets-detection.md)
- [Docker](https://www.docker.com/get-started), with the Compose plugin
- The Ruby and Node.js versions in [.tool-versions](/.tool-versions), for example with
  [mise](https://mise.jdx.dev) (`mise install`) or [asdf](https://asdf-vm.com) (`asdf install`)
- Chrome or Chromium, for the JavaScript specs
- System libraries used by gems: `shared-mime-info`, the PostgreSQL client libraries (`libpq`),
  `libproj` and ImageMagick/libvips (see [the devcontainer Dockerfile](/.devcontainer/Dockerfile)
  for the Debian package names)

### Setup

1. Clone the repository and add your `.env` file.
2. Install the dependencies:
   ```bash
   corepack enable   # Yarn 4
   bundle install
   yarn install
   ```
3. Run `bin/setup --skip-server`. It starts the database and creates and seeds it. (Without
   `--skip-server` it would go on to run `bin/dev`, which keeps running and blocks the terminal.)
   The database is PostgreSQL with PostGIS, started by `docker compose up -d --wait` from
   [`compose.yaml`](/compose.yaml). That file is for local development only. It has its
   own project name and data volume, so it never clashes with the devcontainer. The database
   listens on `127.0.0.1:5432` with user `postgres` and no password, which matches Rails'
   default `DATABASE_URL` in `config/database.yml`, so there is nothing to configure.
   Redis is not needed: it is only the production cache store.
4. Prepare the test databases:
   ```bash
   RAILS_ENV=test bin/rails db:create parallel:create parallel:load_schema
   ```
5. Generate the ATS API OpenAPI document, which some specs read. It is git-ignored, so a fresh clone
   doesn't have it, and without it about 45 specs fail with `No such file or directory @ rb_sysopen -
   .../swagger/v1/swagger.yaml`. It needs the test database from the previous step:
   ```bash
   bundle exec rake rswag:specs:swaggerize
   ```
   Run it again after changing the ATS API specs or controllers.
6. Run the application with `bin/dev`. It makes sure the database is running first (so this is
   all you need from now on), then starts:
   - The Rails application on http://localhost:3000
   - An asset build task each for JavaScript and CSS
   - Solid Queue for processing background jobs

`bin/dev` and `bin/setup` skip starting the database inside a container, when Docker is not
installed, or when `SKIP_DEV_DB=1` is set (for example if you run your own PostGIS).

### Running the tests

The service uses the `parallel_tests` gem:

```bash
CI=1 bundle exec rake parallel:spec
```

Without `CI=1` (or `HEADLESS=1`) the JavaScript specs open a visible browser, which helps when
debugging. Set `PARALLEL_TEST_PROCESSORS` in your shell to control how many processes run. See
[tests and linting](/documentation/development/tooling/testing.md) for more.

### Working in git worktrees

In a new git worktree, run `bin/setup-worktree`. It symlinks the git-ignored `.env`,
`.env.development.local`, `.env.test.local` and `mise.local.toml` files from the main checkout and
installs the JavaScript and Ruby dependencies. Without it `bin/dev` fails on the missing
`node_modules` and environment variables.

All worktrees share the one database container from `compose.yaml` (it has a fixed project name),
so `bin/dev` finds it already running. Don't run specs in two worktrees at the same time unless
each uses its own `TEST_ENV_NUMBER`.

### Managing the database

```bash
docker compose stop      # stop it, keeping the data
docker compose start     # start it again
docker compose down -v   # delete it, including all data
docker compose exec db psql -U postgres tvs_development
```

Only one thing can listen on port 5432. `bin/dev-db` checks this and, if something else holds the
port, prints what it is and stops. Stop that service (or the devcontainer's database) and run it
again. See [Troubleshooting](#troubleshooting).

### Moving over from the old "Running natively" steps

Previously these docs told you to start the devcontainer's database container. That container keeps
its data in a different volume, so the new database starts empty. Stop the old one first, because
both use port 5432:

```bash
docker compose -p teaching-vacancies_devcontainer -f .devcontainer/docker-compose.yml stop db
```

Then either re-seed by running `bin/setup --skip-server` (step 3 above), or bring your data across.
To do that, dump the old database before stopping it, and restore it into the new one (the
`template0` option gives `pg_restore` an empty database to install PostGIS into):

```bash
docker compose -p teaching-vacancies_devcontainer -f .devcontainer/docker-compose.yml exec -T db \
  pg_dump -U postgres -Fc tvs_development > tvs_development.dump
# stop the old container and start the new one (bin/dev-db), then:
docker compose exec -T db createdb -U postgres -T template0 tvs_development
docker compose exec -T db \
  pg_restore -U postgres -d tvs_development --no-owner < tvs_development.dump \
  && rm tvs_development.dump   # only after a successful restore; the dump may hold personal data
```

If you set `DATABASE_URL` in `.env.development.local` or `.env.test.local` for the old setup, it
keeps working.

## Option 2: Devcontainer

This project uses [devcontainers](https://code.visualstudio.com/docs/remote/create-dev-container)
to provide a self-contained environment. See [the devcontainer documentation](/documentation/development/tooling/devcontainer.md)
for how it works and how to customise it.

You will need [Git](https://github.com/git-guides/install-git),
[Docker Desktop](https://www.docker.com/get-started) (started before you begin) and
[Visual Studio Code](https://code.visualstudio.com).

1. Clone the repository and add your `.env` file.
2. Open the folder in VS Code and, when prompted, choose "Reopen in container".
3. The container builds and runs first-run tasks, which takes between 5 and 10 minutes depending on
   your computer. Wait for the terminal to display "`Done. Press any key to close the terminal.`"
4. Run the application by clicking "▶️ Start app" in the status bar, using the VS Code "Run task"
   option, or `bin/dev`.

Run the tests with `CI=1 bundle exec rake parallel:spec`. The devcontainer has its own database
container, and does not use `compose.yaml`.

## Troubleshooting

- **`bin/setup` fails with `role "postgres" does not exist`, or `bin/dev-db` says something is
  already listening on port 5432.** Another PostgreSQL is using the port, most often one installed
  with Homebrew (`brew install postgresql`) or Postgres.app. Rails connects to it instead of the
  Docker database, and it has no `postgres` user. Check with `lsof -nP -iTCP:5432 -sTCP:LISTEN`,
  stop it (for Homebrew, find its name with `brew services list` and run
  `brew services stop <name>`), and run `bin/setup --skip-server` again. You don't need a local
  PostgreSQL server for this project. Keep the `libpq` formula, which provides the client libraries
  the `pg` gem builds against.
- **`bin/setup` stops with "The development database did not start".** That is deliberate: the
  later steps can't work without the database. Read the error above the message, fix it and rerun.
  If you run your own PostGIS, set `SKIP_DEV_DB=1` so `bin/setup` doesn't try to start Docker.
- **I see "Page Not Found" when I log in and try to create a job listing.** Try
  [seeding the database](/documentation/development/tooling/data.md) (quick) or importing the
  school data (slow) if you have not already. When your sign-in account was created, it was
  assigned to a school via a URN, and you may not have a school in your database with the same URN.

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
