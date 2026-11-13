# Store geocoding results in a database table

**Date: 2026-11-06**

## Status

**Decided**

## Context and Problem Statement

[ADR 0015](0015_replace_redis_cache_with_solid_cache.md) replaces the Redis-backed `Rails.cache`
with Solid Cache. `Geocoding` (`lib/geocoding.rb`) stored the coordinates of every searched
location in `Rails.cache` for 180 days. We receive over 70k location searches a day, and each
avoided Google Geocoding API call saves money, so this retention matters.

Solid Cache is a FIFO cache. Its expiry task only deletes the oldest rows, either when `max_size`
or `max_entries` is exceeded or when they are older than `max_age` (default 2 weeks). It does not
track reads, and it does not remove entries early when their own `expires_in` passes. This clashes
with how we use the cache:

- `max_age` caps every entry, so a 180-day `expires_in` would silently become 2 weeks.
- Raising `max_age` to 180 days for the whole cache would keep thousands of short-lived entries
  (Rack::Attack counters, landing page counts, similar jobs) for 180 days. When the size limit is
  reached, the oldest rows go first, and those are the geocoding results.
- Redis ran with an LRU eviction policy, so frequently searched locations survived. Solid Cache
  has no equivalent.

## Decision Outcome

Geocoding results are not cache data: they have a business-defined retention and a real cost to
recompute. We store them in a `geocoded_locations` table in the primary database, and leave Solid
Cache at its defaults for genuinely disposable data. We do not split the cache database or add
infrastructure.

- Lookups are normalised (trimmed, squished, downcased) and unique.
- A row is fresh for 180 days. Google "no match" results are stored for 7 days.
- A stale row is refreshed from Google, and is still returned if the refresh fails.
- A daily job deletes rows older than 1 year.
- A one-off rake task, `geocoding:import_from_redis_cache`, copies the existing Redis entries
  (keeping their remaining lifetime) so that switching stores does not trigger a wave of API calls.
  Until the Solid Cache switch removes it, `Geocoding` also reads the legacy Redis entry on a miss.
- The table is excluded from the DfE Analytics export. `google_geocoding_api_hit` events keep
  tracking API usage.

### Negative Consequences

- Every location search now reads from PostgreSQL, using a unique index on `query`.
- `Geocoding#postcode_from_coordinates` had no callers and is removed, instead of being migrated.
