# Native Rails with a dockerised database as the primary local development setup

**Date: 2026-10-16**

## Status

**Decided**

Amends [ADR 0011](0011_use_devcontainers.md).

## Context and Problem Statement

[ADR 0011](0011_use_devcontainers.md) added devcontainers as an option, with a view to making them
the "official" default way of running the service. In practice many developers run Rails natively
on their own machine and only run PostgreSQL with PostGIS in Docker. They kept doing so because the
app is fast and simple to run natively.

The documentation did not reflect this. It called the devcontainer the "gold standard", described
the native route only in collapsed sections that borrowed the devcontainer's compose file, and
kept an obsolete "legacy" setup guide. Redis is no longer needed in development or test (it is
only the production cache store), which leaves PostgreSQL with PostGIS as the only dependency
worth containerising.

## Decision Outcome

- The primary local setup is Rails running natively, with PostgreSQL and PostGIS in Docker, started
  from the dedicated `compose.yaml` at the repository root.
- `bin/setup` and `bin/dev` start that database automatically (through `bin/dev-db`), unless they
  run inside a container or `SKIP_DEV_DB` is set.
- The devcontainer remains fully supported as an alternative.
- `compose.yaml` is for local development only. It has its own Compose project name and
  data volume, so it cannot clash with the devcontainer or with other environments.
- `legacy-setup.md` is removed; `quick_start.md` presents both setups.

### Positive Consequences

- The documented setup matches how the team works.
- One tested compose file replaces each developer's own PostgreSQL setup.
- The database needs no configuration: the default `DATABASE_URL` in `config/database.yml` works.

### Negative Consequences

- Developers manage Ruby, Node.js and Chrome on their own machine (`mise` or `asdf` read
  `.tool-versions`).
- Developers who used the devcontainer's database container start with an empty database in the
  new volume and have to re-seed it or copy their data across.
