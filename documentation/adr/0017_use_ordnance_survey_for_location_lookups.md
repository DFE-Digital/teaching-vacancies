# Use Ordnance Survey instead of Google for location lookups and suggestions

**Date: 2026-11-10**

## Status

**Decided**

## Context and Problem Statement

Jobseekers and hiring staff type free-text locations (postcodes, towns, areas) into vacancy search,
job alerts, job preferences and vacancy addresses. We need coordinates for those terms. The location
fields (vacancy search, job alerts, job preferences, organisation and college search) also have an
autocomplete.

Searches for areas we hold ONS boundaries for do not need a lookup. For everything else we use the
**Google Geocoding API** for coordinates. Ordnance Survey is used only when Google reports that we
are over quota. The autocomplete suggests whatever the **Google Places Autocomplete API** returns,
and every keystroke calls that paid API.

The Google Geocoding API is one of our highest Google Cloud costs, with tens of thousands of
location searches a day.

To contain that cost we cache every geocoding result for 180 days (`Geocoding::CACHE_DURATION`).
That relies on the cache keeping popular entries for a long time: today `Rails.cache` is Redis,
which normally evicts the least recently used entries, so frequently searched locations stay. We
are moving to Solid Cache ([ADR 0015](0015_replace_redis_cache_with_solid_cache.md)), which evicts
entries first in, first out (FIFO) to stay within its size and age limits. Under FIFO, entries are
removed in the order they were written, whether or not they are still being used, so a long-lived,
cost-saving geocoding cache can no longer be relied on. Every evicted location would be a new paid
Google call, on a workload of tens of thousands of searches a day.

Ordnance Survey is the authoritative source of geographic data for the public sector in Great
Britain. Its [OS Names API](https://docs.os.uk/os-apis/accessing-os-apis/os-names-api) is
OpenData, free to use under the Open Government Licence, and covers place names and postcodes
across Great Britain. Teaching Vacancies only lists jobs in England. The Register of placement
schools service has already
[replaced Google with Ordnance Survey](https://becoming-a-teacher.design-history.education.gov.uk/register-of-placement-schools/replacing-google-maps-api-with-ordnance-survey-api/)
for geocoding, and users saw no change in how search behaves.

Moving geocoding alone is not enough, because the suggestions and the lookups must agree. Most
Google suggestions are streets, stations and businesses ("Clapham High Street", "New York Nails,
Romford") that Ordnance Survey place search cannot match, so about two thirds of the suggestions
people picked still went to the paid Google Geocoding API. Google also names places by a nearby
locality that Ordnance Survey does not record ("Bolton Abbey, Skipton"). We want every suggestion to
be something Ordnance Survey resolves, to the place the suggestion names. The search box asks for
"a postcode, town or region".

Should Ordnance Survey or Google be the primary provider for geocoding, and where should the
autocomplete get its suggestions?

## Decision Drivers

- Reducing the cost of location lookups and suggestions.
- Making geocoding independent of cache retention, so that moving the cache to Solid Cache
  ([ADR 0015](0015_replace_redis_cache_with_solid_cache.md)), with its FIFO eviction, does not
  turn into a cost problem.
- Using the authoritative public sector source for geographic data.
- Consistency with other DfE services.
- Suggestions and lookups agreeing, so that a picked suggestion does not go to paid Google.
- Keeping the user experience: postcode, town and area search should not get noticeably worse.

## Considered Options

For geocoding:

1. Keep Google as primary, with Ordnance Survey only as the over-quota fallback (today's setup).
2. Use Ordnance Survey only and remove Google.
3. Use Ordnance Survey as primary, and Google as a fallback when Ordnance Survey returns no match.

For the autocomplete:

1. Keep Google Places suggestions.
2. Suggest from a local copy of OS Open Names, searched by prefix.
3. Suggest from the OS Names API on each keystroke.
4. The [OS Places API](https://docs.os.uk/os-apis/accessing-os-apis/os-places-api). It returns
   addresses, not towns ("You can't: Locate general areas such as cities"), so it does not fit a
   "postcode, town or region" field.

## Decision Outcome

Chosen options: **geocoding 3, Ordnance Survey first, with Google as a fallback**, and
**autocomplete 3, the OS Names API.**

### Geocoding

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
- The OS Places API, available to DfE through the Public Sector Geospatial Agreement, remains an
  option if we later need address-level lookups.

### Autocomplete

The OS Names API matches whole words fuzzily, not prefixes: "Nott" returns Bott End, Knott Oak and
Nottingham. `LocationSuggestion` therefore:

- suggests up to two regions, counties or cities we hold a polygon for ("Essex"), searched by area as
  before;
- asks the OS Names API for the places matching the search, keeps those in England whose name, or a
  later word of a town or suburb ("Leam" finds Royal Leamington Spa), starts with it, and ranks them
  as `Geocoding` does;
- labels each place "Name, qualifier" ("Clapham, London", "Caldecote, South Cambridgeshire") with
  the first of London, district, county or region for which `Geocoding` picks exactly that place. The
  district comes before the county because the response for a partial search may not include every
  place with the name, and the narrower qualifier is less likely to be shared by one it doesn't see;
- suggests postcodes in England once the search looks like the start of one ("SW4 0");
- lists first where the search goes with the text as typed, if no suggestion is picked: the polygon
  it names, otherwise the place `Geocoding` picks ("Kingston" lists Kingston upon Thames first,
  "Durham" the city of Durham).

We built and measured option 2 too. Both were equally accurate. Option 3 needs no data file to keep
up to date and can suggest partial postcodes, at the cost of one Ordnance Survey call per keystroke.

### Positive Consequences

- Most lookups no longer reach Google, so the Google bill drops sharply. There are no Places API
  calls, and far fewer Geocoding API calls.
- Location data comes from the authoritative public sector source, at no cost.
- Geocoding no longer depends on long-lived cache entries, which removes the architectural
  conflict with Solid Cache's FIFO eviction and unblocks the Redis retirement.
- We follow the same approach as other DfE services.
- Terms Ordnance Survey cannot match, such as misspellings or landmarks, still resolve through
  Google, so search does not get worse.
- Every suggestion resolves to what it names through Ordnance Survey or our polygons, without
  Google. In testing with real calls across 244 inputs, all 886 suggestions did (135 areas, 727
  places, 24 postcodes). Where Ordnance Survey or a polygon resolves the text as typed, it lands on
  the place listed first (123 of 123).
- A town is suggested after a median of 3 letters: 66 of 69 test places by the 4th letter.
- Of the Google suggestions that were places Ordnance Survey knows, 93% (119 of 128) are also
  suggested, at the same place.

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
- Streets, stations, schools and businesses are no longer suggested. They can still be typed and
  searched, and go to the Google Geocoding fallback. So does a fragment searched without picking a
  suggestion ("Manch").
- Places outside England are no longer suggested.
- Ordnance Survey APIs are throttled. The OS Names API allows 600 calls a minute per live project,
  shared by geocoding and the autocomplete, so bulk lookups must stay within that limit. Cache
  evictions in Solid Cache mean more OS calls than with a long-lived cache, so this limit needs watching.
- Each keystroke (after 3 characters, debounced) is an Ordnance Survey call, of about 250 ms.
  `caches_action` on the suggestion endpoint saves repeat searches. If Ordnance Survey fails, only
  polygon areas are suggested.
- Evicted entries that OS cannot match still go to Google. The 180-day `CACHE_DURATION` is left
  unchanged for now; whether to shorten it is a follow-up once we see how Solid Cache behaves in
  production.
- Locations saved before this change (job alerts, job preferences) keep their Google wording and are
  geocoded as before.
