# Searching by Location

## Index
- [Introduction](#introduction)
- [Our approach](#our-approach)
- [How we store locations](#how-we-store-locations)
  - [Meaning of SRID 4326](#meaning-of-srid-4326)
  - [Why not just Geometry](#why-not-just-geometry)
  - [Performance](#performance)
    - [Spatial indexing](#spatial-indexing)
    - [Reducing Location Polygon areas complexity](#reducing-location-polygon-areas-complexity)
    - [Precomputing data when possible](#precomputing-data-when-possible)
    - [Tweaking queries to improve performance](#tweaking-queries-to-improve-performance)
    - [Increasing our database instance resources](#increasing-our-database-instance-resources)
- [Vacancies location](#vacancies-location)
- [How do we get the coordinates for the search location](#how-do-we-get-the-coordinates-for-the-search-location)
- [Location Polygons](#location-polygons)
  - [Purpose](#purpose)
  - [Mappings](#mappings)
- [Getting the geographical coordinates](#getting-the-geographical-coordinates)
  - [Location autocomplete](#location-autocomplete)
  - [Google Geocoding API costs](#google-geocoding-api-costs)


## Introduction

Jobseekers searching for vacancies within a relative distance from a location is a core feature in Teaching Vacancies.

At the time this was written, around 70% of our vacancy searches include location in their filters.

## Our approach

Once a job search location is submitted, the service:

1. Gets the area or coordinates for the searched location.

2. Filters vacancies that, after being included by the rest of the search filters, are located within the provided radius distance from the given location.

3. To allow ordering the search results by distance, computes the exact distance between each vacancy and the given location.

## How we store locations

Our PostgreSQL database instance has the PostGIS extension.
This extension allows our database to store and operate with geospatial data.

The data type in the database is `geometry` with the `geographic: true` flag and `SRID 4326`.

What does this mean?

We store the data in a geographic coordinate system (GCS) rather than a projected coordinate system (PCS).
The coordinates are stored as latitude and longitude on the Earth's surface, following the WGS84 standard.

Using the `geometry` type with `geographic: true` allows us to leverage a wide range of PostGIS geospatial functions, such as `ST_Distance`, `ST_Within`, `ST_Intersects`, and `ST_Buffer`.

### Meaning of `SRID 4326`

- SRID: Spatial Referencing System ID.
- 4326: Represents spatial data using longitude and latitude coordinates on the Earth's surface as defined in the WGS84 standard.

The result of this is that the spatial data specifies the Earth as an ellipsoid, and uses elliptical geometry.

The data type we use from PostGIS is `Geometry` with a `Geographic` coordinate system, which allows us to use projections and transformations.

### Why not just Geometry

When using a geographic coordinate system, distance calculations are performed on the curved surface of the Earth.
PostGIS functions like `ST_Distance` and `ST_Buffer` will take into account the Earth's curvature, providing more accurate results for large distances compared to a planar (flat) coordinate system.

There is no papertrail on why Geographic data was chosen over Geogmetric when the feature was built, so we will assume it was for precission.

Given that our service longest distances on the search are "within 200 miles from X location in England", using Earths ellipsoid (meant for long intercontinental or across multiple countries precission)
doesn't seem a requirement for our service purpose. And it has major performance costs:

### Performance

Using `Geographic` data and operations over the earth's ellipsoid it is very expensive computationally compared to using planar `Geometric` data.

We have mitigated the performance hit with a few measures:

#### Spatial indexing

We use PostGIS spatial indexing for any geospatial data used in our queries. Stored areas and points must have spatial indexes when used in any querying.

#### Reducing Location Polygon areas complexity

We have experienced major performance issues when some of our location polygons coming from ONS have tens of thousands of points (e.g., the Cornwall polygon consisted of 125k points).

Doing an `ST_Buffer` (expanding the polygon for radius searches) over polygons with that level of complexity is very taxing on the database CPU and memory.

Simplifying the polygons with some tolerance offers a major reduction in the polygon points while quite accurately keeping the polygon shape.
For example, the Cornwall polygon with 2.5k points instead of 125k is almost identical to the original while being way less resource-expensive to operate with.

To achieve that, we use `ST_SimplifyPreserveTopology` over the ONS imported polygons prior to storing them in our database.

#### Precomputing data when possible

Precomputing the `centroid` point for the location polygon areas and saving them in the database improves our search by distance queries performance. It avoids calculating each location polygon center to use it to calculate the polygon distance from each vacancy. Instead, it uses the stored centroid to calculate the distance.

#### Tweaking queries to improve performance

The `use_spheroid` parameter set to `false` improves the performance of operations by using a faster spherical calculation instead of a more computationally expensive ellipsoidal calculation.

For example: `ST_Distance(gg1, gg2, false)`

#### Increasing our database instance resources

We originally had a basic Azure PostgreSQL Flexible server: `GP_Standard_D2ds` with 2 vCPUs and 8GB of RAM.

The memory was more than enough, the average CPU usage was low, the connections limit was well above what we were using... but our database CPU kept getting daily 100% usage spikes with location search queries, causing some very slow queries that triggered AKS pods restarting in our servers.

We upgraded to a `GP_Standard_D4ds`, which provides 4 vCPUs and 16GB of RAM.

The increase in CPU resources resolved the location search SQL queries performance issues. While they're still computationally expensive, the database instance has more than enough resources to swiftly manage those queries without choking or causing a bottleneck.

## Vacancies location

Each vacancy has location coordinates stored in their `geolocation` database field.

This field contains the geographic coordinates for the vacancy associated organization.

## How do we get the coordinates for the search location

Once a location is provided for a search, there are three possibilities:

1. The location is considered a **nationwide location** (e.g., England, UK..)

    We ignore the location. A nationwide location filter is irrelevant when all our vacancies are restricted to England.

2. **We have a polygon** stored for the given location.

    We create a buffered expanded area based on the provided search location radius.

3. **No polygon is found** for the given location.

    We get the geographical coordinates for the given location, from Ordnance Survey first and Google as a fallback (see [Getting the geographical coordinates](#getting-the-geographical-coordinates)).

## Location Polygons

The location polygons are geographical areas we store in our database.

There is an [ImportPolygonDataJob](/app/jobs/import_polygon_data_job.rb) running weekly that imports polygons for:
- Counties
- Cities
- Regions

It also creates composite polygons combining the above.

All these imports are obtained [querying](/app/services/ons_data_import/base.rb) the ONS (Office for National Statistics) ArcGIS endpoints to obtain the area data for each of the polygons.

### Purpose

There is a difference between searching for vacancies within a particular distance from a jobseeker's home (that would match some particular coordinates point) and vacancies within a particular distance "from Essex".

How do we measure the distance between a whole region and a particular vacancy location?

Taking the center of the region would be wrong. As if, let's say, we search for "10 miles from Essex" anything over 10 miles from Essex center point would be filtered out.

What we would expect is to find anything 10 miles away from Essex outer borders.

Having an area stored for "Essex" containing its borders, allows us to combine `ST_Buffer` and `ST_DWithin` to first expand the area borders to cover the provided search radius, and then find if any vacancy location is contained within that expanded area.

### Mappings

Within the [mapping files](/config/data/ons_mappings/) we define the subset of cities, regions and counties we store polygon areas for. This is used by the [location data setup](/config/initializers/location_data.rb).

The [mapped locations file](/config/data/ons_mappings/mapped_locations.yml) helps to match common location search terms with an appropriate location polygon if any.

**Warning**: There is no papertrail on why/how this approach was taken.
The current team knowledge and understanding on this area is very limited and based on tracking the implementation/configuration files, that are quite complex.

## Getting the geographical coordinates

As many location search terms don't match a polygon name, the service falls back to obtaining the location coordinates.

We use the [Geocoding class](/lib/geocoding.rb) to retrieve and cache the location coordinates. The [OS Names API](https://docs.os.uk/os-apis/accessing-os-apis/os-names-api) (Ordnance Survey, free OpenData) is tried first, and the Google Geocoding API is only called when Ordnance Survey has no match or is unavailable. We don't call Google because we dislike the Ordnance Survey result. See [ADR 0017](/documentation/adr/0017_use_ordnance_survey_for_location_lookups.md).

Ordnance Survey is asked for one term only: a UK postcode if the search contains one, otherwise the first part of the search (trailing country parts such as ", UK", which Google Places autocomplete adds, are ignored). We search the Ordnance Survey place types city, town, suburban area, village, other settlement, hamlet and postcode; the geocoder gem's own filter leaves out suburban areas, which Ordnance Survey uses for places such as the London districts. The matching is in [`Geocoding::OrdnanceSurveyMatcher`](/lib/geocoding/ordnance_survey_matcher.rb):

- **Postcode:** an exact postcode match in England is used. Vacancy addresses and trust postcodes mostly follow this path.
- **Place name:** of the places in England whose name matches the first part of the search (and, for comma-separated searches, whose name, district, county or region matches every remaining part), one is chosen:
  1. The most important type wins: city, then town, then suburban area or "other settlement", then village, then hamlet. Ordnance Survey labels large places such as Clapham, Hackney and Wimbledon "Other Settlement", so they rank above villages and hamlets.
  2. A place in London ranks at least as a town and wins ties. Searches for ambiguous names such as Acton or Sutton mostly mean the London one, which is also what Google returns.
  3. The largest place wins: Ordnance Survey has no population, so the size of the place's bounding box stands in for how prominent it is.

  For a bare name, towns and cities with a longer name starting with it as a whole word (Newcastle upon Tyne) also compete, unless an exact match is already a town or city.

  If nothing in England, or anywhere, is called exactly the first part of the search, places containing it as whole words are used, except villages and hamlets (Tooting finds Upper Tooting, Leamington Spa finds Royal Leamington Spa, Hull finds Kingston upon Hull). If another country has a place called exactly that (Cardiff), Google answers instead.

  The location autocomplete used to offer Google Places suggestions such as "Bolton Abbey, Skipton" or "New York, North Shields", which job alerts and job preferences still hold. The part after the comma is a nearby locality that Ordnance Survey doesn't record against the place (it only knows its county, district and region). When no place with the name is in a county, district or region matching that part, we look the locality up in Ordnance Survey too and use the place with the name that is closest to it, if it is within 20 km. This costs one more Ordnance Survey call, and only when the search has a locality that doesn't match.

Google is used when there is no Ordnance Survey match at all: a name or postcode Ordnance Survey doesn't have, a place only in Wales or Scotland, an outward postcode district such as "SW4" typed alone, a search whose locality we can't place near the name, a typed street, station or business (Ordnance Survey holds roads and stations, but we only search places), an error, or no API key.

If Google reports it is over quota, the first Ordnance Survey result in England is used as a last resort and is not cached.

In testing against Google's real answers, Ordnance Survey answered about 95% of typed place names, and nine in ten of its answers were within 5 km of Google's. The differences are mostly ambiguous names (Newton, Whitchurch, Clifton) where Google's own choice is hard to predict.

### Location autocomplete

The location fields ("Enter a postcode, town or region") suggest locations from [`LocationSuggestion`](/app/services/location_suggestion.rb) instead of Google Places (see [ADR 0017](/documentation/adr/0017_use_ordnance_survey_for_location_lookups.md)), so that every suggestion is something the search resolves without Google:

- up to two regions, counties or cities we hold a polygon for, searched by area;
- places in England from the OS Names API. The API matches whole words fuzzily ("Nott" returns Bott End before Nottingham), so we keep only the places whose name, or a later word of a town or suburb ("Leam" finds Royal Leamington Spa), starts with the search, and rank them as `Geocoding` does. Each is labelled "Name, qualifier" ("Clapham, London", "Caldecote, South Cambridgeshire") with the first of London, district, county or region for which `Geocoding` picks that same place;
- postcodes in England, once the search looks like the start of one ("SW4 0").

Job alerts, job preferences and the school and college search use the same autocomplete and resolve locations the same way: a polygon by name, otherwise `Geocoding`. The UK check on job alert and job preference locations (`WithinUnitedKingdomValidator`) accepts a polygon name without a lookup, as Ordnance Survey has no place called "Essex".

Where the search goes with the text as typed, if no suggestion is picked, is listed first: the polygon it names, otherwise the place `Geocoding` picks ("Kingston" lists Kingston upon Thames first, "Durham" the city of Durham), so the list agrees with the search.

Each keystroke after the third (debounced) is one OS Names API call. The API allows 600 calls a minute per project, shared with geocoding; the suggestion endpoint is cached with `caches_action`. If Ordnance Survey fails, only polygon areas are suggested.
