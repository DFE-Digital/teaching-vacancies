# Using Buildpacks on PaaS Instead of Containers

**Date: 2020-04-14**

## Status

**Decided**

## Parties Involved

 * Brendan Quinn
 * Colin Saliceti
 * Davide Dippolito
 * Todd Tyree

## Context

We chose GOV.UK PaaS to simplify our infrastructure and reduce our time to deploy and our ongoing maintenance overheads.

In order to [maximize the support we receive from GOV.UK
PaaS](https://docs.cloud.service.gov.uk/responsibility_model.html#standard-buildpack-responsibilities) during our
transition, and ensure we do not engage in unnecessary clean-up work on our existing-poorly configured-docker
containers, we have decided to use
[buildpacks](https://docs.cloud.service.gov.uk/deploying_apps.html#deploy-an-app-to-production) initially.

## Decision

TVS will be run using buildpacks when it goes live on GOV.UK PaaS. In order to bring the infrastructure in-line with
departmental standards, this will be reviewed and changed to docker containers when resources and time permit. 

## Consequences

Developers will need to work on environments with configurations that diverge from the production environment. This
should not present serious challenges as TVS is a [12-factor app](https://12factor.net/), the codebase is
straightforward and all the same versions of the supporting software (Postgresql, redis and elasticsearch at the time of
writing) are available pre-packaged for our development environments.  We can further mitigate any risk arising from the
difference because we are able to quickly commission and decommission test environments in PaaS. These will be otherwise
identical to production. 
