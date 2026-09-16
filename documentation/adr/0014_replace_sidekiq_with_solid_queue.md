# Replace Sidekiq with Solid Queue for background jobs

**Date: 2026-05-27**

## Status

**Decided**

## Context and Problem Statement

Teaching Vacancies runs its background jobs (emails, job alerts, integrations, scheduled tasks and
analytics events) with [Sidekiq](https://github.com/sidekiq/sidekiq). Sidekiq stores its queues in
Redis, which we host as an **Azure Cache for Redis** instance dedicated to jobs (`redis-queue` in
`terraform/app/modules/paas/aks_redis.tf`), alongside a second instance for the Rails cache. In
production both instances run on the Premium tier.

Microsoft has announced the
[retirement of Azure Cache for Redis](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/retirement-faq).
The Basic, Standard and Premium tiers will be retired, and Microsoft recommends migrating to
**Azure Managed Redis**, a separate product with its own pricing plans. In response, DfE has shared
a direction with its service teams to move away from existing Azure Cache for Redis instances, and
to avoid the cost of Azure Managed Redis where a service does not need Redis.

We therefore have to change how our job queues are hosted. Either we move the Redis instance behind
Sidekiq to Azure Managed Redis, or we move to a job backend that does not need Redis.

Since Rails 8, the framework default for background jobs is
[Solid Queue](https://github.com/rails/solid_queue), which stores jobs in the application's
relational database. We already run PostgreSQL for the service.

Should we keep Sidekiq on Azure Managed Redis, or move our background jobs to Solid Queue?

## Decision Drivers

- The retirement of Azure Cache for Redis, and DfE's direction to move away from it.
- Being held back on old versions: Sidekiq 7 needs Redis 6.2 or later, but our Azure Cache for
  Redis instances run Redis 6.0. That pins us to Sidekiq 6, and through it constrains other gems
  such as Rack.
- Reducing hosting costs: every Redis instance we remove is one fewer managed service to pay for.
- Simplifying our infrastructure: fewer backing services to provision, monitor, patch and secure.
- Aligning with current Rails defaults, which makes upgrades and onboarding easier and reduces
  reliance on third-party gems.
- Keeping job features we depend on: scheduled (recurring) jobs, retries, concurrency limits (for
  example, to avoid overwhelming the GOV.UK Notify API) and a dashboard to inspect and retry failed
  jobs.

## Considered Options

- Keep Sidekiq, and move its Redis instance to Azure Managed Redis.
- Replace Sidekiq with Solid Queue, backed by our existing PostgreSQL database.

## Decision Outcome

We will replace Sidekiq with **Solid Queue**, storing jobs in our existing PostgreSQL database.

- Jobs move to Solid Queue queue by queue, so the migration can be done and verified gradually.
- Recurring jobs move to Solid Queue's scheduler (`config/recurring.yml`).
- Workers and queues are configured in `config/queue.yml` and run with `bin/jobs`.
- [Mission Control – Jobs](https://github.com/rails/mission_control-jobs) replaces the Sidekiq
  dashboard, mounted at `/solid_queue_jobs` behind support user authentication.
- Once no jobs run through Sidekiq, we remove Sidekiq, its gems, its infrastructure and the Redis
  instance used for job queues.

Replacing the Rails cache's Redis instance is a separate decision, recorded in
[ADR 0015](0015_replace_redis_cache_with_solid_cache.md).

### Positive Consequences

- No Redis instance to host for job queues, removing its cost and its exposure to the Azure Cache
  for Redis retirement.
- One fewer backing service to provision, monitor and secure.
- Jobs can be enqueued in the same database transaction as the records they relate to, so a job is
  never enqueued for a change that was rolled back.
- Follows the Rails default, supported by the Rails core team, with less third-party code.
- Removing Sidekiq also removes the Sidekiq 6 pin and the version constraints it placed on other
  dependencies, such as Rack.

### Negative Consequences

- Job processing adds load to our PostgreSQL database, which now has to be sized and monitored for
  it as well as for application traffic.
- Solid Queue workers need more memory than Sidekiq workers did.
- Solid Queue is younger than Sidekiq, with a smaller ecosystem and less operational experience in
  the team.
- Migrating jobs gradually means running both systems side by side for a while.
