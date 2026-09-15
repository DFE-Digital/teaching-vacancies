# Replace Redis with Solid Cache for the Rails cache

**Date: 2026-05-27**

## Status

**Decided**

## Context and Problem Statement

The Rails cache (`Rails.cache`) in production uses `:redis_cache_store`, backed by an **Azure Cache
for Redis** instance dedicated to caching (`redis-cache` in
`terraform/app/modules/paas/aks_redis.tf`). In production it runs on the Premium tier.

Besides general caching, this cache also holds the request counters that
[Rack::Attack](https://github.com/rack/rack-attack) uses for throttling and blocking abusive
clients, so it must be shared across all application instances.

The same retirement that led us to replace Sidekiq ([ADR 0014](0014_replace_sidekiq_with_solid_queue.md))
applies here. Microsoft has announced the
[retirement of Azure Cache for Redis](https://learn.microsoft.com/en-us/azure/azure-cache-for-redis/retirement-faq)
in favour of **Azure Managed Redis**, and DfE has shared a direction with its service teams to move
away from existing Azure Cache for Redis instances, and to avoid the cost of Azure Managed Redis
where a service does not need Redis.

Since Rails 8, the framework default cache store is
[Solid Cache](https://github.com/rails/solid_cache), which stores cache entries in a relational
database rather than in memory. We already run PostgreSQL for the service, and it is already
hosting our background jobs through Solid Queue.

Should we move our cache to Azure Managed Redis, or replace it with Solid Cache?

## Decision Drivers

- The retirement of Azure Cache for Redis, and DfE's direction to move away from it.
- Reducing hosting costs: removing the cache instance, after the queue instance, means we no longer
  pay for any managed Redis service.
- Simplifying our infrastructure: with Solid Queue and Solid Cache, PostgreSQL is the only data
  store the application needs, in every environment including local development.
- Aligning with current Rails defaults.
- Keeping a cache shared across application instances, so Rack::Attack throttling keeps working.

## Considered Options

- Keep `:redis_cache_store`, and move its Redis instance to Azure Managed Redis.
- Replace the Redis cache with Solid Cache, backed by PostgreSQL.

## Decision Outcome

We will replace the Redis cache with **Solid Cache**, backed by PostgreSQL, and remove Redis from
the service entirely.

Removing Redis entirely also means moving everything else that talks to Redis directly. The main
case is vacancy view tracking, which counts views per referrer in Redis
(`VacancyAnalyticsService`, `TrackVacancyViewJob`, `AggregateVacancyReferrerStatsJob`). That
approach relies on Redis-specific operations, such as scanning keys by pattern, so it will need to
be reworked rather than simply pointed at Solid Cache.

Once nothing uses Redis, we remove the Redis gems, the `REDIS_CACHE_URL` and `REDIS_QUEUE_URL`
configuration, the Redis instances in Terraform and the Redis service in the devcontainer.

### Positive Consequences

- No managed Redis service left to pay for, and no exposure to the Azure Cache for Redis
  retirement.
- One data store to provision, back up, monitor and secure.
- Simpler local development and test setup, with no Redis container.
- A cache held on disk can be much larger than a memory-bound one for the same cost, and it is not
  lost when an instance restarts.
- Follows the Rails default.

### Negative Consequences

- Reading from and writing to a database-backed cache is slower than an in-memory Redis cache.
  This is acceptable for our workload, but should be watched on hot paths.
- Rack::Attack writes a counter on almost every request, which adds write load to PostgreSQL. We
  need to monitor this, and may need to host the cache in a separate database if it affects the
  application.
- The database now carries application data, background jobs and the cache, making PostgreSQL an
  even more critical single dependency to size and monitor.
- Vacancy view tracking has to be reworked before Redis can be removed.
