# Use Ordnance Survey for geocoding, with Google as a fallback

**Date: 2026-11-10**

## Status

**Decided**

## Context and Problem Statement

Jobseekers and hiring staff type free-text locations (postcodes, towns, areas) into vacancy search,
job alerts, job preferences and vacancy addresses. We need coordinates for those terms.

Searches for areas we hold ONS boundaries for do not need a lookup. For everything else we use the
**Google Geocoding API** for coordinates. Ordnance Survey is used only when Google reports that we
are over quota.

The Google Geocoding API is one of our highest Google Cloud costs, with tens of thousands of
location searches a day.

To contain that cost we cache every geocoding result for 180 days (`Geocoding::CACHE_DURATION`).
That relies on the cache keeping popular entries for a long time: today `Rails.cache` is Redis,
which normally evicts the least recently used entries, so frequently searched locations stay. We
are moving to Solid Cache ([ADR 0015](0015_replace_redis_cache_with_solid_cache.md)), which evicts
entries first in, first out (FIFO) to stay within its size and age limits. Under FIFO, entries are removed in the order
they were written, whether or not they are still being used, so a long-lived, cost-saving geocoding
cache can no longer be relied on. Every evicted location would be a new paid Google call, on a
workload of tens of thousands of searches a day.

Ordnance Survey is the authoritative source of geographic data for the public sector in Great
Britain. Its [OS Names API](https://docs.os.uk/os-apis/accessing-os-apis/os-names-api) is
OpenData, free to use under the Open Government Licence, and covers place names and postcodes
across Great Britain. Teaching Vacancies only lists jobs in England. The Register of placement
schools service has already
[replaced Google with Ordnance Survey](https://becoming-a-teacher.design-history.education.gov.uk/register-of-placement-schools/replacing-google-maps-api-with-ordnance-survey-api/)
for geocoding, and users saw no change in how search behaves.

Should Ordnance Survey or Google be the primary provider for geocoding?

## Decision Drivers

- Reducing the cost of location lookups.
- Making geocoding independent of cache retention, so that moving the cache to Solid Cache
  ([ADR 0015](0015_replace_redis_cache_with_solid_cache.md)), with its FIFO eviction, does not
  turn into a cost problem.
- Using the authoritative public sector source for geographic data.
- Consistency with other DfE services.
- Keeping the user experience: postcode, town and area search should not get noticeably worse.

## Considered Options

1. Keep Google as primary, with Ordnance Survey only as the over-quota fallback (today's setup).
2. Use Ordnance Survey only and remove Google.
3. Use Ordnance Survey as primary, and Google as a fallback when Ordnance Survey returns no match.

## Decision Outcome

Chosen option: **3, Ordnance Survey first, with Google as a fallback.**

- Geocoding of free-text locations comes from the OS Names API. A postcode is used when it matches
  exactly. A place name is used whenever Ordnance Survey has a match in England: when several
  places share the name, the most important type wins, then London, then the largest place. The
  details are in [Searching by location](/documentation/service/technical/searching-by-location.md).
- Google is called only when Ordnance Survey has no usable match or is unavailable. It is not
  called because we would prefer a different Ordnance Survey result: the aim is to use Ordnance
  Survey as much as possible.
- A cache miss no longer costs money: it is a free OS call. The cache becomes a latency
  optimisation rather than a cost control, so Solid Cache's FIFO eviction is acceptable and we do
  not need a long-lived, guaranteed-retention cache for location data.
- We monitor how often the Google fallback is used. If it turns out to be negligible, we revisit
  removing Google entirely (option 2).
- The [OS Places API](https://docs.os.uk/os-apis/accessing-os-apis/os-places-api), available to
  DfE through the Public Sector Geospatial Agreement, remains an option if we later need
  address-level lookups.

### Positive Consequences

- Most lookups no longer reach Google, so the Google bill drops sharply.
- Location data comes from the authoritative public sector source, at no cost.
- Geocoding no longer depends on long-lived cache entries, which removes the architectural
  conflict with Solid Cache's FIFO eviction and unblocks the Redis retirement.
- We follow the same approach as other DfE services.
- Terms Ordnance Survey cannot match, such as misspellings or landmarks, still resolve through
  Google, so search does not get worse.

### Negative Consequences

- Two location providers to maintain and monitor instead of one.
- Ordnance Survey is weaker than Google at fuzzy matching, so misspelt terms rely on the
  fallback.
- Ordnance Survey has no measure of prominence, so for ambiguous names (Newton, Whitchurch,
  Clifton) its pick can differ from Google's, which is itself hard to predict. We rank by place type,
  prefer London, then prefer the largest place. In testing against real Google answers, nine in ten
  Ordnance Survey answers were within 5 km of Google's and Ordnance Survey answered about 95% of
  realistic searches; the monitoring in the decision above shows the real rate.
- Foreign place names that are also English place names now resolve to the English place.
  Google, restricted to Great Britain, returned the UK centre point for some of them (Sydney, New
  York), which the UK location check treated as outside the UK. Ordnance Survey returns Sydney in
  Cheshire or New York in Rotherham instead, so a job preference location of "Sydney" is now
  accepted. We accept this to keep Google as a fallback only.
- Ordnance Survey APIs are throttled (600 requests a minute per live project), so bulk lookups must stay within their limits. Cache
  evictions in Solid Cache mean more OS calls than with a long-lived cache, so this limit needs
  watching.
- Evicted entries that OS cannot match still go to Google. The 180-day `CACHE_DURATION` is left
  unchanged for now; whether to shorten it is a follow-up once we see how Solid Cache behaves in
  production.
