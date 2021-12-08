# Environments after GOV&#46;UK PaaS migration

**Date: 10/02/2020**

## Status

**Discussing**

## Context

We're migrating the Teacher Vacancy application to GOV&#46;UK PaaS and we want
to rethink and simplify our delivery process and what environments we're using
to aid development, testing and deployment.

This is especially relevant as we are moving away from
[Gitflow](https://datasift.github.io/gitflow/IntroducingGitFlow.html) toward
a simple usage of Git (refer to ADR003). Not having long-living branches we can utilise a simpler environments setup.

The current setup is this:

* **testing** - user researchers to conduct usability testing sessions
* **edge** - devs to test or debug features, code and integrations in isolation
* **staging** - final quality assurance step and demos
* **production** - the live service


## Decision

We will reduce the number of environment to:

* **staging** - used for User Acceptance testing, quality assurance testing and demos
* **production** - the live service, runs the latest version of the main branch

Developers will use local environments to test or debug features, code and integrations.
The same applies to user researchers when conducting usability testing sessions.


Having a staging environment is also handy to test builds and deployments before
going to production. Keeping a staging environment close to production reduces
the risk of having unexpected issues when deploying a release.

## Consequences

Reducing the number of environments results in less maintenance overhead.
It's also worth mentioning that GOV&#46;UK PaaS makes the process to spin up a new environment fairly trivial.
In case there's a need for an extra environment for a short amount of time
we're able to spin a new one, deploy to it and tear it down reasonably quickly.
