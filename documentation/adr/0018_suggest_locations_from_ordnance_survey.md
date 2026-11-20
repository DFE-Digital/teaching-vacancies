# Suggest locations from Ordnance Survey instead of Google Places

**Date: 2026-11-20**

## Status

**Decided**

## Context and Problem Statement

The location fields (vacancy search, job alerts, job preferences, organisation and college search)
have an autocomplete. It suggested whatever the Google Places Autocomplete API returned, and the
chosen text was then geocoded, since [ADR 0017](0017_use_ordnance_survey_for_location_lookups.md)
by Ordnance Survey first.

The two did not agree. Most Google suggestions are streets, stations and businesses ("Clapham High
Street", "New York Nails, Romford") that Ordnance Survey place search cannot match, so about two
thirds of the suggestions people picked still went to the paid Google Geocoding API. Google also
names places by a nearby locality that Ordnance Survey does not record ("Bolton Abbey, Skipton").
Every keystroke also called the paid Places API.

We want every suggestion to be something Ordnance Survey resolves, to the place the suggestion
names. The search box asks for "a postcode, town or region".

## Considered Options

1. Keep Google Places suggestions.
2. Suggest from a local copy of OS Open Names, searched by prefix.
3. Suggest from the OS Names API on each keystroke.
4. The OS Places API. It returns addresses, not towns ("You can't: Locate general areas such as
   cities"), so it does not fit a "postcode, town or region" field.

## Decision Outcome

Chosen option: **3, the OS Names API.**

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
- suggests postcodes in England once the search looks like the start of one ("SW4 0").

We built and measured option 2 too. Both were equally accurate. Option 3 needs no data file to keep
up to date and can suggest partial postcodes, at the cost of one Ordnance Survey call per keystroke.

### Positive Consequences

- Every suggested place geocodes to itself through Ordnance Survey, without Google. In testing with
  real calls, 751 of 751 place suggestions did, across 107 typed inputs and 134 random prefixes, and
  so did all suggested postcodes.
- A town is suggested after a median of 3 letters: 66 of 69 test places by the 4th letter.
- Of the Google suggestions that were places Ordnance Survey knows, 93% (119 of 128) are also
  suggested, at the same place.
- No Places API calls, and far fewer Geocoding API calls.

### Negative Consequences

- Streets, stations, schools and businesses are no longer suggested. They can still be typed and
  searched, and go to the Google Geocoding fallback.
- Places outside England are no longer suggested.
- Each keystroke (after 3 characters, debounced) is an Ordnance Survey call, of about 250 ms. The
  OS Names API allows 600 calls a minute per project, shared with geocoding; `caches_action` on the
  suggestion endpoint saves repeat searches. If Ordnance Survey fails, only polygon areas are
  suggested.
- Locations saved before this change (job alerts, job preferences) keep their Google wording and are
  geocoded as before.
